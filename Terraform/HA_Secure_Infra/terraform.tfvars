# Customize these values for your deployment
# This file is optional - defaults from variables.tf will be used if not provided

aws_region    = "us-east-1"
project_name  = "ha-app"
vpc_cidr      = "10.0.0.0/16"
instance_type = "t3.micro"

# Example for different configurations:
# aws_region    = "us-west-2"
# project_name  = "production-app"
# vpc_cidr      = "172.16.0.0/16"
# instance_type = "t3.small"