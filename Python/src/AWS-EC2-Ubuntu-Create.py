import boto3

# Create an EC2 client
ec2 = boto3.client('ec2',
    aws_access_key_id='',
    aws_secret_access_key='',
    region_name='us-east-1'            
    )

# Define instance parameters
instance_params = {
    'ImageId': 'ami-084568db4383264d4',  # Replace with your desired AMI
    'InstanceType': 't2.micro',  # Replace with your desired instance type
    'MinCount': 1,
    'MaxCount': 1,
    'KeyName': 'ssh-key',  # Replace with your key pair name
    'SecurityGroupIds': ['sg-048e851c58d65e32b'], # Replace with your security group ID(s)
    'SubnetId': 'subnet-045bf79f9aeab413a', # Replace with your Subnet ID
    'TagSpecifications': [
        {
            'ResourceType': 'instance',
            'Tags': [
                {
                    'Key': 'Name',
                    'Value': 'My Ubuntu Base Image'
                }
            ]
        }
    ]
}

# Launch the instance
response = ec2.run_instances(**instance_params)
print(response)

# Get the instance ID
instance_id = response['Instances'][0]['InstanceId']
print(f"Instance ID: {instance_id}")
