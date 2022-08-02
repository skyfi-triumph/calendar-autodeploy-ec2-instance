import datetime
import json
import os
import sys
import time

import boto3

from botocore.exceptions import ClientError
from dateutil.relativedelta import relativedelta
from google.oauth2 import service_account
from googleapiclient.discovery import build


NOW = time.strftime("%Y-%m-%d-%H:%M:%S", time.gmtime())
REGION = os.environ['REGION']
CALENDAR_ID = os.environ['CALENDAR_ID']
SCOPES = ['https://www.googleapis.com/auth/calendar']
APPLICATION_NAME = 'Google Calendar'
AWS_ACCOUNT = os.environ['AWS_ACCOUNT']


def lambda_handler(_event, _context):
    # get google calendar service account credentials
    credentials = service_account.Credentials.from_service_account_info(json.loads(get_secret()), scopes=SCOPES)
    delegated_credentials = credentials.with_subject(CALENDAR_ID)
    # poll google calendar for events
    # extract relevant details from each event
    items_with_summary_start_end = get_calendar(delegated_credentials)
    # create cw event that will start instance in correct region
    create_cloudwatch_event_rules(items_with_summary_start_end)


def get_secret():
    secret_name = "google-calendar-serviceaccount" # create a secret in AWS Secrets Manager with your google calendar service account you create for api calls
    # Create a Secrets Manager client
    session = boto3.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=REGION
        )
    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    secret_value = get_secret_value_response["SecretString"]
    return secret_value


def cronify(time_string):
    d = time_string.replace('-', ',').replace(' ', ',').replace(':', ',').split(',')
    return f"cron({d[4]} {d[3]} {d[2]} {d[1]} ? {d[0]})"


def get_calendar(delegated_credentials):
    service = build('calendar', 'v3', credentials=delegated_credentials)
    all_events_in_calendar = service.events().list(
        calendarId=CALENDAR_ID,
        timeMin=(datetime.datetime.utcnow().isoformat() + 'Z'),
        maxResults=10,
        singleEvents=True,
        orderBy='startTime'
        ).execute()
    items_with_summary = [item for item in all_events_in_calendar['items'] if item.get('summary')]
    items_with_summary_start_end = {item['summary']: {'start': item['start'], 'end': item['end'],
                                                      'description': item.get('description')} for item in items_with_summary}
    print(json.dump(items_with_summary_start_end, sys.stdout, indent=2))
    return items_with_summary_start_end


def create_cloudwatch_event_rules(items_with_summary_start_end):
    # Create Cloudwatch Event rule to start the EC2 instance
    cw_client = boto3.client('events', region_name=REGION)
    for item in items_with_summary_start_end.items():
        # Skip this item if it has no description
        if 'description' not in item[1].keys():
            print('Item has no description! Skipping...')
            continue
        print(item[1]['description'])
        # Good description example
        # 'Peter_Parker\ng4dn.xlarge\nus-east-1'
        if '\n' not in item[1]['description']:
            print('Found a description, but it is malformed! Skipping...')
            continue
        target_region = item[1]['description'].split('\n')[2]
        # If the google calendar event's region doesn't match the region in which this lambda function is deployed, then do nothing.
        if target_region != REGION:
            print(f"Found a description, but the description region was {target_region} and this function only creates instances in region {REGION}. Skipping...")
            continue
        # Determine if the time zone offset plus or minus relative to UTC
        utc_direction = item[1]['start']['dateTime'][-6]
        # Determine number of hours difference from UTC
        offset_from_utc = int(item[1]['start']['dateTime'].split(utc_direction)[-1][0:2])
        if utc_direction == '-':
            offset_from_utc = offset_from_utc * -1
        start_time_adjusted_for_time_zone = datetime.datetime.fromisoformat(
            item[1]['start']['dateTime']) - relativedelta(hours=offset_from_utc)
        # We need to subtract 15 minutes from start time in order to allow the Instance to start before scheduled event
        fifteen_minutes_before_start = start_time_adjusted_for_time_zone - relativedelta(minutes=15)
        # Find end time and create END_TIME to pass to ec2_start_stop_function to create END_TIME event rule
        utc_direction_end = item[1]['end']['dateTime'][-6]
        # Determine number of hours difference from UTC
        offset_from_utc_end = int(item[1]['end']['dateTime'].split(utc_direction_end)[-1][0:2])
        if utc_direction_end == '-':
            offset_from_utc_end = offset_from_utc_end * -1
        end_time_adjusted_for_time_zone = datetime.datetime.fromisoformat(
            item[1]['end']['dateTime']) - relativedelta(hours=offset_from_utc_end)
        # Add 2 minutes from end time in order to compensate for user login time
        two_minutes_after_end = end_time_adjusted_for_time_zone + relativedelta(minutes=2)
        end_time_cron = cronify(str(two_minutes_after_end))
        # Ensure the same EventBridge Rule isn't created multiple times
        rule_name = str(int(datetime.datetime.timestamp(fifteen_minutes_before_start)))
        existing_rules = cw_client.list_rules()
        names_of_existing_rules = [rule['Name'] for rule in existing_rules['Rules']]
        if rule_name in names_of_existing_rules:
            continue
        instance_type = item[1]['description'].strip().split('\n')[1]
        cw_client.put_rule(
            Name=rule_name,
            ScheduleExpression=cronify(str(fifteen_minutes_before_start)),
            State='ENABLED',
            Description=f"Trigger ec2_start_stop_function to create {instance_type} at {cronify(str(fifteen_minutes_before_start))} in {REGION}.")
        cw_client.put_targets(
            Rule=str(int(datetime.datetime.timestamp(fifteen_minutes_before_start))),
            Targets=[{
                'Id': 'ec2_start_stop_function',
                'Arn': f"arn:aws:lambda:{REGION}:{AWS_ACCOUNT}:function:ec2_start_stop_function",
                'Input': json.dumps({"action": "create", "USER": item[1]['description'].strip().split('\n')[0],  "INSTANCE_TYPE": instance_type, "START_TIME": start_time_adjusted_for_time_zone, "END_TIME": end_time_cron, "RULE_NAME": rule_name})
                }]
            )
