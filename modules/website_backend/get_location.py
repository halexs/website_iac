import json
import boto3

def lambda_handler(event, context):
    print("event: ", event)
    print("context: ", context)
    # s3 = boto3.resource('s3')
    # content_object = s3.Object('kaelnomads-resources', 'locations.json')
    # file_content = content_object.get()['Body'].read().decode('utf-8')
    # json_content = json.loads(file_content)
    
    # return {
    #     'statusCode': 200,
    #     'body': json_content
    # }
    # return {
    #     'statusCode': 200,
    #     'body': json.dumps("hello test from another world")
    # }
    # return {
    #     'statusCode': 200,
    #     'body': json.dumps('Hello from Lambda!')
    # }
    # return {
    #     'statusCode': 200,
    #     'body': str("hello from lambda p2")
    # }
    return {
        "statusCode": 200,
        "body": "{'Test': 'Test'}",
        "headers": {
            'Content-Type': 'text/html',
        }
    }

