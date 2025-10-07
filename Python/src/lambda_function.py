import json
import boto3
import os
from azure.storage.blob import BlobServiceClient

# Initialize S3 client
s3_client = boto3.client('s3')

# Azure Blob Storage credentials
connection_string = os.environ.get('AZURE_STORAGE_CONNECTION_STRING')
container_name = os.environ.get('AZURE_CONTAINER_NAME')

def lambda_handler(event, context):
    # Get the S3 bucket and object key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    
    # Get the S3 object
    s3_object = s3_client.get_object(Bucket=bucket_name, Key=object_key)
    
    # Initialize the Azure Blob client
    blob_service_client = BlobServiceClient.from_connection_string(connection_string )
    blob_client = blob_service_client.get_blob_client(container=container_name, blob=object_key)
    
    # Stream the data directly from S3 to Azure Blob Storage
    blob_client.upload_blob(s3_object['Body'].read(), overwrite=True)
    
    return {
        'statusCode': 200,
        'body': json.dumps('File transferred from S3 to Azure Blob Storage successfully!')
    }
