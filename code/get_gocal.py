import datetime, re
import googleapiclient.discovery
import google.auth
 
# Preparation for Google API
SCOPES = ['https://www.googleapis.com/auth/calendar.readonly']
calendar_id = 'xxxxx'
gapi_creds = google.auth.load_credentials_from_file('credentials.json', SCOPES)[0]
service = googleapiclient.discovery.build('calendar', 'v3', credentials=gapi_creds)
 
# Get events from Google Calendar API
now = datetime.datetime.utcnow().isoformat() + 'Z'
events_result = service.events().list(
     calendarId=calendar_id, timeMin=now,
     maxResults=5, singleEvents=True,
     orderBy='startTime').execute()
 
# Pick up only start time, end time and summary info
events = events_result.get('items', [])
formatted_events = [(event['start'].get('dateTime', event['start'].get('date')), # start time or day
     event['end'].get('dateTime', event['end'].get('date')), # end time or day
     event['summary']) for event in events]
 
# Generate output text
response = '[Closest 5 events]\n'
for event in formatted_events:
     if re.match(r'^\d{4}-\d{2}-\d{2}$', event[0]):
         start_date = '{0:%Y-%m-%d}'.format(datetime.datetime.strptime(event[1], '%Y-%m-%d'))
         response += '{0} All Day\n{1}\n\n'.format(start_date, event[2])
     # For all day events
     else:
         start_time = '{0:%Y-%m-%d %H:%M}'.format(datetime.datetime.strptime(event[0], '%Y-%m-%dT%H:%M:%S+00:00'))
         end_time = '{0:%H:%M}'.format(datetime.datetime.strptime(event[1], '%Y-%m-%dT%H:%M:%S+00:00'))
         response += '{0} ~ {1}\n{2}\n\n'.format(start_time, end_time, event[2])
response = response.rstrip('\n')
print(response)