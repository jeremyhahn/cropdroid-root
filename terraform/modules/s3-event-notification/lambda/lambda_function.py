import os
import json
import boto3

def lambda_handler(event, context):
    region        = os.environ['REGION']
    target_bucket = os.environ['TARGET_BUCKET']
    target_key    = os.environ['TARGET_KEY']
    sns_arn       = os.environ['NOTIFICATION_ARN']

    client = boto3.client('sns')

    retval = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "Region ": region,
            "Bucket" : target_bucket,
            "Artifact": target_key,
            "SNS": sns_arn,
            "Event": event
        })
    }

    response = client.publish (
        TargetArn = sns_arn,
        Subject = f"Artifact {target_key} updated",
        Message = json.dumps({"default": json.dumps(retval)}),
        MessageStructure = "json")

    return retval
