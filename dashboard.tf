resource "aws_cloudwatch_dashboard" "main" {
  count = var.state == "init" ? var.ec2_count : 0

  dashboard_name = "ObjectiveRealityGames-${module.ec2[count.index].id}"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "GPUStats",
            "GPUUtilization",
            "InstanceID",
            "${module.ec2[count.index].id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "GPUUtilization"
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "GPUStats",
            "MemoryUtilization",
            "InstanceID",
            "${module.ec2[count.index].id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "GPUMemUtilization"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "CustomMetrics",
            "Memory Usage",
            "InstanceID",
            "${module.ec2[count.index].id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "CPUMemUsage"
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "CustomMetrics",
            "C: Usage",
            "InstanceID",
            "${module.ec2[count.index].id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "C: Usage"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "GPUStats",
            "MemoryUsed",
            "InstanceID",
            "${module.ec2[count.index].id}"
          ],
          [
            "GPUStats",
            "MemoryFree",
            "InstanceID",
            "${module.ec2[count.index].id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "GPUMemUsage"
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "CustomMetrics",
            "C: Free",
            "InstanceID",
            "${module.ec2[count.index].id}"
          ],
          [
            "CustomMetrics",
            "C: Total",
            "InstanceID",
            "${module.ec2[count.index].id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "C: MemUsage"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "CustomMetrics",
            "Total Memory",
            "InstanceID",
            "${module.ec2[count.index].id}"
          ],
          [
            "CustomMetrics",
            "Free Memory",
            "InstanceID",
            "${module.ec2[count.index].id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "CPUMemUtilization"
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "GPUStats",
            "DisplayActive",
            "InstanceID",
            "${module.ec2[count.index].id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "DisplayActive"
      }
    }
  ]
}
EOF
}