import os

import boto3


def lambda_handler(_event, _context):
    region = os.getenv("AWS_REGION_FOR_CW_DASHBOARD")

    # Set up boto3 clients / resources
    cw_client = boto3.client('cloudwatch')
    ec2_resource = boto3.resource('ec2', region_name=region)

    # Find all running EC2 Instances created by Triumph Tech
    instances = ec2_resource.instances.filter(
        Filters=[
            {'Name': 'instance-state-name', 'Values': ['running']},
            {'Name': 'tag:Created By', 'Values': ['Triumph Tech']}
        ]
    )

    # Set values for CloudWatch Dashboard Widget template(s)
    GPUUtilization_template = '["GPUStats", "GPUUtilization", "InstanceID", "{}"]'
    GPUMemoryUtilization_template = '["GPUStats", "GPUMemoryUtilization", "InstanceID", "{}"]'
    GPULatency_template = '["GPUStats", "GPULatency", "InstanceID", "{}"]'
    MemoryUsage_template = '["CustomMetrics", "Memory Usage", "InstanceID", "{}"]'
    DisplayActive_template = '["GPUStats", "DisplayActive", "InstanceID", "{}"]'

    # Initialize blank arrays (will hold CW Dashboard Widgets)
    GPUUtilization_array = []
    GPUMemoryUtilization_array = []
    GPULatency_array = []
    MemoryUsage_array = []
    DisplayActive_array = []

    # For all running EC2 Instances created by Triumph Tech:
    for instance in instances.all():
        print(instance.id)
        GPUUtilization_array.append(GPUUtilization_template.format(instance.id))
        GPUMemoryUtilization_array.append(
            GPUMemoryUtilization_template.format(instance.id))
        GPULatency_array.append(GPULatency_template.format(instance.id))
        MemoryUsage_array.append(MemoryUsage_template.format(instance.id))
        DisplayActive_array.append(DisplayActive_template.format(instance.id))

    GPUUtilization_string = ",".join(GPUUtilization_array)
    GPUMemoryUtilization_string = ",".join(GPUMemoryUtilization_array)
    GPULatency_string = ",".join(GPULatency_array)
    MemoryUsage_string = ",".join(MemoryUsage_array)
    DisplayActive_string = ",".join(DisplayActive_array)

    GPUUtilization_instances = r'{"type": "metric", "x": 0, "y": 0, "width": 8, "height": 6, "properties": {"metrics": ['+GPUUtilization_string + \
        r'], "view":"timeSeries", "stacked": false, "region": "'+region + \
        r'", "stat": "Average", "period": 5, "title": "GPUUtilization" }}'
    GPUMemoryUtilization_instances = r'{"type": "metric", "x": 8, "y": 0, "width": 8, "height": 6, "properties": {"metrics": ['+GPUMemoryUtilization_string + \
        r'], "view":"timeSeries", "stacked": false, "region": "'+region + \
        r'", "stat": "Average", "period": 5, "title": "GPUMemUtilization" }}'
    GPULatency_instances = r'{"type": "metric", "x": 16, "y": 0, "width": 8, "height": 6, "properties": {"metrics": ['+GPULatency_string + \
        r'], "view":"timeSeries", "stacked": false, "region": "'+region + \
        r'", "stat": "Average", "period": 5, "title": "GPULatency" }}'
    MemoryUsage_instances = r'{"type": "metric", "x": 0, "y": 6, "width": 8, "height": 6, "properties": {"metrics": ['+MemoryUsage_string + \
        r'], "view":"timeSeries", "stacked": false, "region": "'+region + \
        r'", "stat": "Average", "period": 5, "title": "CPUMemUsage" }}'
    DisplayActive_instances = r'{"type": "metric", "x": 8, "y": 6, "width": 8, "height": 6, "properties": {"metrics": ['+DisplayActive_string + \
        r'], "view":"timeSeries", "stacked": false, "region": "'+region + \
        r'", "stat": "Average", "period": 5, "title": "DisplayActive" }}'

    print(GPUUtilization_instances)

    # Delete the old Dashboards
    cw_client.delete_dashboards(
        DashboardNames=['Custom-GPUMetrics'])

    # Create the new Dashboards
    cw_client.put_dashboard(DashboardName='Custom-GPUMetrics',
                                       DashboardBody='{"widgets": ['+GPUUtilization_instances+','+GPUMemoryUtilization_instances+','+GPULatency_instances+','+MemoryUsage_instances+','+DisplayActive_instances+']}')
