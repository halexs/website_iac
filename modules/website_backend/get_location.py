import json
import boto3

def lambda_handler(event, context):
    # TODO implement
    # s3 = boto3.client('s3')
    s3 = boto3.resource('s3')
    # s3.download_file('kael-nomads-resources', 'locations.json')
    # content_object = s3.Object('kael-nomads-resources', 'locations.json')
    # locations.json may need the actual coordinates
    content_object = s3.Object('kaelnomads-resources', 'locations.json')
    file_content = content_object.get()['Body'].read().decode('utf-8')
    json_content = json.loads(file_content)
    
    # with open('loc.json', 'wb') as data:
    #     s3.download_fileobj('kael-nomads-resources', 'locations.json', data)
    
    return {
        'statusCode': 200,
        'body': json_content
    }
    # return {
    #     'statusCode': 200,
    #     'body': json.dumps("hello test from another world")
    # }
    # return {
    #     'statusCode': 200,
    #     'body': json.dumps('Hello from Lambda!')
    # }
