import json
import boto3

def lambda_handler (event, context):
    ec2_client = boto3.client('ec2')
    CW_client = boto3.client('cloudwatch')
    regions = ['us-east-1']
    for region in regions:
        ec2 = boto3.resource('ec2', region_name=region)
        instances = ec2.instances.filter(
            Filters=[
                {'Name': 'instance-state-name', 'Values': ['running']},
                {'Name': 'tag:Created By', 'Values': ['Triumph Tech']}
            ]
        )
        
        GPUUtilization_template = '["GPUStats", "GPUUtilization", "InstanceID", "{}"]'
        GPUMemoryUtilization_template = '["GPUStats", "GPUMemoryUtilization", "InstanceID", "{}"]'
        GPULatency_template = '["GPUStats", "GPULatency", "InstanceID", "{}"]'
        MemoryUsage_template = '["CustomMetrics", "Memory Usage", "InstanceID", "{}"]'
        DisplayActive_template = '["GPUStats", "DisplayActive", "InstanceID", "{}"]'

        
        GPUUtilization_array = []
        GPUMemoryUtilization_array = []
        GPULatency_array = []
        MemoryUsage_array = []
        DisplayActive_array = []
        
        
        for i in instances.all():
            print(i.id)
            instance_id = i.id
            GPUUtilization_array.append(GPUUtilization_template.format(i.id))
            GPUMemoryUtilization_array.append(GPUMemoryUtilization_template.format(i.id))
            GPULatency_array.append(GPULatency_template.format(i.id))
            MemoryUsage_array.append(MemoryUsage_template.format(i.id))
            DisplayActive_array.append(DisplayActive_template.format(i.id))
            
        
        GPUUtilization_string = ",".join(GPUUtilization_array)
        GPUMemoryUtilization_string = ",".join(GPUMemoryUtilization_array)
        GPULatency_string = ",".join(GPULatency_array)
        MemoryUsage_string = ",".join(MemoryUsage_array)
        DisplayActive_string = ",".join(DisplayActive_array)
        
        
        GPUUtilization_instances = r'{"type": "metric", "x": 0, "y": 0, "width": 8, "height": 6, "properties": {"metrics": ['+GPUUtilization_string+r'], "view":"timeSeries", "stacked": false, "region": "'+region+r'", "stat": "Average", "period": 5, "title": "GPUUtilization" }}'
        GPUMemoryUtilization_instances = r'{"type": "metric", "x": 8, "y": 0, "width": 8, "height": 6, "properties": {"metrics": ['+GPUMemoryUtilization_string+r'], "view":"timeSeries", "stacked": false, "region": "'+region+r'", "stat": "Average", "period": 5, "title": "GPUMemUtilization" }}'
        GPULatency_instances = r'{"type": "metric", "x": 16, "y": 0, "width": 8, "height": 6, "properties": {"metrics": ['+GPULatency_string+r'], "view":"timeSeries", "stacked": false, "region": "'+region+r'", "stat": "Average", "period": 5, "title": "GPULatency" }}'
        MemoryUsage_instances = r'{"type": "metric", "x": 0, "y": 6, "width": 8, "height": 6, "properties": {"metrics": ['+MemoryUsage_string+r'], "view":"timeSeries", "stacked": false, "region": "'+region+r'", "stat": "Average", "period": 5, "title": "CPUMemUsage" }}'
        DisplayActive_instances = r'{"type": "metric", "x": 8, "y": 6, "width": 8, "height": 6, "properties": {"metrics": ['+DisplayActive_string+r'], "view":"timeSeries", "stacked": false, "region": "'+region+r'", "stat": "Average", "period": 5, "title": "DisplayActive" }}'
                
        print(GPUUtilization_instances)

        CW_client.delete_dashboards(DashboardNames=['ObjectiveRealityGames-GPUMetrics'])

        response = CW_client.put_dashboard(DashboardName='ObjectiveRealityGames-GPUMetrics', 
                                            DashboardBody='{"widgets": ['+GPUUtilization_instances+','+GPUMemoryUtilization_instances+','+GPULatency_instances+','+MemoryUsage_instances+','+DisplayActive_instances+']}')
        