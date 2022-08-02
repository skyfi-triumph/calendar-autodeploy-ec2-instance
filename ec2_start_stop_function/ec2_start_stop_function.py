"""
Lambda function to list/create/start/stop/terminate an ec2 instance.
Event can be passed like:

TO LIST:
{
  "action" : "list"
}

TO CREATE:
{
  "action" : "create",
  "INSTANCE_TYPE" : "g4dn.xlarge",
  "USER" : "TriumphTech",
  "START_TIME" : "2022-08-05T21:00:00-04:00"
  "END_TIME" : "cron(30 15 22 07 ? 2022)"
  "RULE_NAME" : "1661426100"
}

TO TERMINATE:
{
  "action" : "terminate",
  "ins_id" : "i-05d2b0d6716afbc6f"
}

TO START:
{
  "action" : "start",
  "ins_id" : "i-05d2b0d6716afbc6f"
}

TO STOP:
{
  "action" : "stop",
  "ins_id" : "i-05d2b0d6716afbc6f"
}

"""

from datetime import datetime as dt
import json
import os
import time

import boto3

ts = time.gmtime()
now = time.strftime("%Y-%m-%d-%H:%M:%S", ts)
now_unix_timestamp = str(int(dt.now().timestamp()))

AMI = os.environ['AMI']
INSTANCE_TYPE = os.environ['INSTANCE_TYPE']
SUBNET_ID = os.environ['SUBNET_ID']
REGION = os.environ['REGION']
VOLUME_SIZE = os.environ['VOLUME_SIZE']
VOLUME_TYPE = os.environ['VOLUME_TYPE']
AZ = os.environ['AZ']
SUBNET_ID = os.environ['SUBNET_ID']
VPC_SG_IDS = os.environ['VPC_SG_IDS']
IAM_INSTANCE_PROFILE_NAME = os.environ['IAM_INSTANCE_PROFILE_NAME']
IAM_INSTANCE_PROFILE_ARN = os.environ['IAM_INSTANCE_PROFILE_ARN']
S3_BUCKET_INSTANCE_ID = os.environ['S3_BUCKET_INSTANCE_ID']
CUSTOMER = os.environ['CUSTOMER']
APPLICATION = os.environ['APPLICATION']
STAGE = os.environ['STAGE']
AWS_ACCOUNT = os.environ['AWS_ACCOUNT']

ec2_resource = boto3.resource('ec2', region_name=REGION)
ec2_client = boto3.client('ec2', region_name=REGION)
s3_client = boto3.client('s3', region_name=REGION)
cw_client = boto3.client('events', region_name=REGION)


def list_instances():
    #   Lists all the ec2 instances with their state, public Ip, tags.
    instances = {}
    for instance in ec2_resource.instances.all():
        instances[instance.id] = {
            "type": instance.instance_type,
            "public_ip": instance.public_ip_address,
            "state": instance.state.get('Name'),
            "tag": instance.tags
            }
    for i in instances.items():
        print(i)
    return instances


def create_instances(user, instance_type, start_time, end_time, rule_name):
    instance = ec2_resource.create_instances(
        ImageId=AMI,
        InstanceType=instance_type,
        SubnetId=SUBNET_ID,
        MaxCount=1,
        MinCount=1,
        BlockDeviceMappings=[
            {
                'DeviceName': '/dev/sda1',
                'Ebs': {
                    'VolumeSize': 250,
                    'VolumeType': VOLUME_TYPE
                    }
                },
            ],
        SecurityGroupIds=[
            VPC_SG_IDS
            ],
        IamInstanceProfile={
            'Name': IAM_INSTANCE_PROFILE_NAME
            },
        TagSpecifications=[
            {
                'ResourceType': 'instance',
                'Tags': [
                    {
                        'Key': 'Created By',
                        'Value': 'Triumph Tech',
                        },
                    {
                        'Key': 'Name',
                        'Value': f"{CUSTOMER}-{APPLICATION}-{STAGE}-{user}-{now}",
                        },
                    {
                        'Key': 'USER',
                        'Value': user,
                        },
                    {
                        'Key': 'Created On',
                        'Value': now,
                        }
                    ],
                },
            ],
        )
    instance[0].wait_until_running()
    instance[0].reload()

    instance_id = instance[0].instance_id
    public_ip = instance[0].public_ip_address
    print(f"InstanceID = {instance_id}")
    print(f"PublicIP = {public_ip}")

    user_bytes = user.encode('utf-8')
    region_bytes = REGION.encode('utf-8')
    start_time_bytes = start_time.encode('utf-8')
    public_ip_bytes = public_ip.encode('utf-8')
    instance_id_bytes = instance_id.encode('utf-8')
    s3_json_str = json.dumps(
        {
            'user': user_bytes.decode('utf-8'),
            'region': region_bytes.decode('utf-8'),
            'public_ip': public_ip_bytes.decode('utf-8'),
            'instance_id': instance_id_bytes.decode('utf-8'),
            'start_time': start_time_bytes.decode('utf-8')
            })

    send_instance_info_to_s3(s3_json_str, user)
    create_cloudwatch_event_rule_to_terminate_instance(instance_id, end_time)
    delete_cloudwatch_event_rule_to_create_instance(rule_name)
    response = public_ip
    return response


def send_instance_info_to_s3(s3_json_str, user):
    s3_client.put_object(
        Body=s3_json_str,
        Bucket=S3_BUCKET_INSTANCE_ID,
        Key=f"{user}/{REGION}/{now_unix_timestamp}"
        )


def create_cloudwatch_event_rule_to_terminate_instance(instance_id, end_time):
    cw_client.put_rule(
        Name=f"{instance_id}",
        ScheduleExpression=end_time,
        State='ENABLED',
        Description='Rule to terminate instance_id from the rule name',
        RoleArn=f"arn:aws:iam::{AWS_ACCOUNT}:role/{CUSTOMER}-{APPLICATION}-{STAGE}-{REGION}-eventbridge_for_lambda"
        )
    cw_client.put_targets(
        Rule=f"{instance_id}",
        Targets=[{
            'Id': 'ec2_start_stop_function',
            'Arn': f"arn:aws:lambda:{REGION}:{AWS_ACCOUNT}:function:ec2_start_stop_function",
            'Input': json.dumps({"action": "terminate", "ins_id": instance_id})
            }]
        )


def delete_cloudwatch_event_rule_to_create_instance(rule_name):
    cw_client.remove_targets(
        Rule=rule_name,
        Ids=[
            'ec2_start_stop_function'
            ]
        )
    cw_client.delete_rule(
        Name=rule_name
        )


def start_instance(instance_id):
    response = ec2_client.start_instances(InstanceIds=[instance_id], DryRun=False)
    return response


def stop_instance(instance_id):
    response = ec2_client.stop_instances(InstanceIds=[instance_id], DryRun=False)
    return response


def terminate_instance(instance_id):
    ec2_client.terminate_instances(InstanceIds=[instance_id], DryRun=False)
    cw_client.remove_targets(
        Rule=instance_id,
        Ids=['ec2_start_stop_function']
        )
    response = cw_client.delete_rule(Name=instance_id)
    return response


def lambda_handler(event, _context):
    data = {}
    print(event)
    if event.get('action') == 'list':
        data = list_instances()
        print(data)
    elif event.get('action') == 'create':
        user = event['USER'].strip()
        end_time = event['END_TIME'].strip()
        rule_name = event['RULE_NAME'].strip()
        start_time = event['START_TIME'].strip()
        instance_type = event['INSTANCE_TYPE'].strip()
        data = create_instances(user, instance_type, start_time, end_time, rule_name)

    elif event.get('action') == 'start':
        ins_id = ''
        data = start_instance(ins_id)

    elif event.get('action') == 'stop':
        ins_id = event['ins_id']
        data = stop_instance(ins_id)

    elif event.get('action') == 'terminate':
        ins_id = event['ins_id']
        data = terminate_instance(ins_id)

    return {
        'statusCode': 200,
        'body': json.dumps(data)
        }
