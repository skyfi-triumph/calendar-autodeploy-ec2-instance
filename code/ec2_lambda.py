import os
import boto3
import time

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

def lambda_handler(event, context):

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
                        'Value': 'objective-reality-games',
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
    return instance_id







"""
Lambda function to list/create/start/stop/terminate/reboot an ec2 instance.
Event can be passed like:
{
  "action" : "list" -> to list all the instances.
           : "create" -> to create all the instances.
           : "start" -> to start a already set instance.
           : "stop" -> to stop a already set instance.
           : "terminate" -> to terminate all the instances.
           : "reboot" -> to reboot all the instances.
}
"""
"""
import json
import boto3

AMI = os.environ['AMI']
INSTANCE_TYPE = os.environ['INSTANCE_TYPE']
KEY_NAME = os.environ['KEY_NAME']
SUBNET_ID = os.environ['SUBNET_ID']
REGION = process.env.AWS_REGION
ec2 = boto3.resource('ec2', region_name = REGION)


def list_instances():
  '''
  Lists all the ec2 instances with their state, public Ip, name etc. 
  '''
    instances = {}
    for instance in ec2.instances.all():
        tags = [i for i in instance.tags if i.get('Value') == 'Cron']  

        # if len(tags)>0:
        instances[instance.id] = {
            "type": instance.instance_type,
            "public_ip": instance.public_ip_address,
            "state": instance.state.get('Name'),
            # "tag": tags
            
            }
        
    for i in instances.items():
        print(i)
        
    return instances


def create_instances(id):
    ec2 = boto3.client('ec2')
    response = ec2.run_instances(
        ImageId=AMI,
        InstanceType=INSTANCE_TYPE,
        KeyName=KEY_NAME,
        MaxCount=1,
        MinCount=1,
        BlockDeviceMappings=[
            {
                'DeviceName': 'string',
                'VirtualName': 'string',
                'Ebs': {
                    'DeleteOnTermination': True|False,
                    'Iops': 123,
                    'SnapshotId': 'string',
                    'VolumeSize': 123,
                    'VolumeType': 'standard'|'io1'|'io2'|'gp2'|'sc1'|'st1'|'gp3',
                    'KmsKeyId': 'string',
                    'Throughput': 123,
                    'OutpostArn': 'string',
                    'Encrypted': True|False
                },
                'NoDevice': 'string'
            },
        ],
        SecurityGroupIds=[
            'string',
        ],
        SecurityGroups=[
            'string',
        ],
        SubnetId='string',
        UserData='string',
        ClientToken='string',
        IamInstanceProfile={
            'Arn': 'string',
            'Name': 'string'
        },
        NetworkInterfaces=[
            {
                'AssociatePublicIpAddress': True|False,
                'DeleteOnTermination': True|False,
                'Description': 'string',
                'DeviceIndex': 123,
                'Groups': [
                    'string',
                ],
                'Ipv6AddressCount': 123,
                'Ipv6Addresses': [
                    {
                        'Ipv6Address': 'string'
                    },
                ],
                'NetworkInterfaceId': 'string',
                'PrivateIpAddress': 'string',
                'PrivateIpAddresses': [
                    {
                        'Primary': True|False,
                        'PrivateIpAddress': 'string'
                    },
                ],
                'SecondaryPrivateIpAddressCount': 123,
                'SubnetId': 'string',
                'AssociateCarrierIpAddress': True|False,
                'InterfaceType': 'string',
                'NetworkCardIndex': 123,
                'Ipv4Prefixes': [
                    {
                        'Ipv4Prefix': 'string'
                    },
                ],
                'Ipv4PrefixCount': 123,
                'Ipv6Prefixes': [
                    {
                        'Ipv6Prefix': 'string'
                    },
                ],
                'Ipv6PrefixCount': 123
            },
        ],
        TagSpecifications=[
            {
                'ResourceType': 'client-vpn-endpoint'|'customer-gateway'|'elastic-ip'|'image'|'instance'|'key-pair',
                'Tags': [
                    {
                        'Key': 'string',
                        'Value': 'string'
                    },
                ]
            },
        ],
        MetadataOptions={
            'HttpTokens': 'optional'|'required',
            'HttpPutResponseHopLimit': 123,
            'HttpEndpoint': 'disabled'|'enabled',
            'InstanceMetadataTags': 'disabled'|'enabled'
        },
        DryRun=True|False,
        )
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
   
def reboot_instance(id):
    ec2 = boto3.client('ec2')
    try:
        ec2.reboot_instances(InstanceIds=[id], DryRun=True)
    except Exception as e:
        if 'DryRunOperation' not in str(e):
            print("You don't have permission to reboot instancess.")
            raise
    
    try:
        response = ec2.reboot_instances(InstanceIds=[id], DryRun=False)
        print('Success', response)
    except Exception as e:
        print('Error', e)


def lambda_handler(event, context):
    # TODO implement
    
    data = {}
    print(event)
    if event.get('action') == 'list':
        data = list_instances()   
        print(data)
    
    elif event.get('action') == 'create':
        ins_id = ''
        data = create_instances(ins_id)

    elif event.get('action') == 'start':
        ins_id = ''
        data = start_instance(ins_id)
    
    elif event.get('action') == 'stop':
        ins_id = ''
        data = stop_instance(ins_id)

    elif event.get('action') == 'terminate':
        ins_id = ''
        data = terminate_instance(ins_id)

    elif event.get('action') == 'reboot':
        ins_id = ''
        data = reboot_instance(ins_id)
 
    return {
        'statusCode': 200,
        'body': json.dumps(data)
    }
    """
