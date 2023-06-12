import boto3
import time
import sys
from urllib.parse import quote_plus
import os

client = boto3.client("logs", region_name='eu-west-2')
timestamp = int(time.time()) * 1000
log_group_name = f"terraform-plan-outputs-{sys.argv[3]}"
log_stream_name = sys.argv[2]

with open(sys.argv[1]) as file:
    log_event = [{'timestamp': timestamp, 'message': file.read()}]

client.create_log_stream(logGroupName=log_group_name, logStreamName=log_stream_name)
print("log stream created")
response = client.put_log_events(logGroupName=log_group_name,
                                 logStreamName=log_stream_name,
                                 logEvents=log_event)
print("log event added")
base_url = "https://eu-west-2.console.aws.amazon.com/cloudwatch/home"
encoded_stream_name = quote_plus(quote_plus(log_stream_name))
fragment = f"logsV2:log-groups/log-group/{log_group_name}/log-events/{encoded_stream_name}"
url = f"{base_url}?region=eu-west-2#{fragment}"
print("url created")
with open(os.environ['GITHUB_OUTPUT'], 'a') as fh:
    print(f"log-url={url}", file=fh)
