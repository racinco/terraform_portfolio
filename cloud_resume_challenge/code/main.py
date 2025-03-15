import json

import boto3
from botocore.exceptions import ClientError

# Create a DynamoDB client
dynamodb = boto3.resource('dynamodb')

# Define the table name
table_name = 'rac_portfolio_visitor_counter'

# Get the DynamoDB table reference
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    # Assuming the primary key of the item you're accessing is 'id'
    # and you are passing the id of the item through the event.
    # item_id = event['id']
    item_id = 'rac_portfolio'
    
    try:
        # Get the current item from DynamoDB
        response = table.get_item(
            Key={
                'user_id': item_id
            }
        )
        
        # Check if the item exists
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'body': 'Item not found'
            }
        
        # Retrieve the current visitor count from the item
        current_visitors = response['Item'].get('visitor_count', 0)
        
        # Increment the visitor count by 1
        new_visitors = current_visitors + 1
        
        # Update the item with the new visitor count
        table.update_item(
            Key={
                'user_id': item_id
            },
            UpdateExpression='SET visitor_count = :val',
            ExpressionAttributeValues={
                ':val': new_visitors
            }
        )
        
        return {
            'statusCode': 200,
            'body': f'Visitor count updated to {new_visitors}'
        }
    
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': f'Error updating item: {e.response["Error"]["Message"]}'
        }
