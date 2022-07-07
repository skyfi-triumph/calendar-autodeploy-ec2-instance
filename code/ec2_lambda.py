
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
  "REGION" : "us-east-1",
  "INSTANCE_TYPE" : "g5.xlarge",
  "TIME" : "2",
  "USER" : "Fredrick"
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

import os
import boto3
import time
import json
import time
ts = time.gmtime()
now = time.strftime("%Y-%m-%d-%H:%M:%S", ts)

AMI = os.environ['AMI']
INSTANCE_TYPE = os.environ['INSTANCE_TYPE']
KEY_NAME = os.environ['KEY_NAME']
SUBNET_ID = os.environ['SUBNET_ID']
REGION = os.environ['REGION']
VOLUME_SIZE = os.environ['VOLUME_SIZE']
VOLUME_TYPE = os.environ['VOLUME_TYPE']
AZ           = os.environ['AZ']
SUBNET_ID                   = os.environ['SUBNET_ID']
VPC_SG_IDS      = os.environ['VPC_SG_IDS']
IAM_INSTANCE_PROFILE_NAME        = os.environ['IAM_INSTANCE_PROFILE_NAME']
IAM_INSTANCE_PROFILE_ARN        = os.environ['IAM_INSTANCE_PROFILE_ARN']

ec2 = boto3.resource('ec2', region_name=REGION)

def list_instances():
#   Lists all the ec2 instances with their state, public Ip, tags. 

    instances = {}
    for instance in ec2.instances.all():
        tags = [i for i in instance.tags if i.get('Created By') == 'Triumph Tech']  

        # if len(tags)>0:
        instances[instance.id] = {
            "type": instance.instance_type,
            "public_ip": instance.public_ip_address,
            "state": instance.state.get('Name'),
            "tag": instance.tags
            }
        
    for i in instances.items():
        print(i)
        
    return instances


def create_instances(REGION,INSTANCE_TYPE,TIME,USER):
    # Create instance

    instance = ec2.create_instances(
        ImageId=AMI,
        InstanceType=INSTANCE_TYPE,
        KeyName=KEY_NAME,
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
                        'Value': f"objective-reality-games-{USER}-{now}",
                    },
                    {
                        'Key': 'TIME',
                        'Value': TIME,
                    },
                    {
                        'Key': 'USER',
                        'Value': USER,
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
    print(f"publicIP = {public_ip}")
    response = public_ip
    return response

def start_instance(id):
    ec2 = boto3.client('ec2')
    response = ec2.start_instances(InstanceIds=[id], DryRun = False)
    return response

def stop_instance(id):
    ec2 = boto3.client('ec2')
    response = ec2.stop_instances(InstanceIds=[id], DryRun=False)
    return response

def terminate_instance(id):
    ec2 = boto3.client('ec2')
    response = ec2.terminate_instances(InstanceIds=[id], DryRun=False)
    return response
   


def lambda_handler(event, context):

    data = {}
    print(event)
    if event.get('action') == 'list':
        data = list_instances()   
        print(data)
    
    elif event.get('action') == 'create':
        REGION = event['REGION']
        INSTANCE_TYPE = event['INSTANCE_TYPE']
        TIME = event['TIME']
        USER = event['USER']
        data = create_instances(REGION,INSTANCE_TYPE,TIME,USER)

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

