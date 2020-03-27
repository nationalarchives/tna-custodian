#!/usr/bin/env python
#initiate from destroy-custodian script
#for testing: python delete-cn7.py --profile management --dry_run
import boto3
import json
import argparse
from botocore.exceptions import ClientError
from datetime import datetime

def json_serial(obj):
    """JSON serializer for objects not serializable by default json code"""

    if isinstance(obj, datetime):
        serial = obj.isoformat()
        return serial
    raise TypeError("Type not serializable")

class awslambda:
    def __init__(self, profile, dry_run):
        self.profile = profile
        self.dry_run = dry_run

        print("Searching for Cloud Custodian Lambda functions in all regions")
        self.session = boto3.session.Session(profile_name=self.profile, region_name='us-east-1')
        self.ec2 = self.session.client('ec2')
        regions = self.ec2.describe_regions()['Regions']
        #print json.dumps(regions, sort_keys=True, indent=2, default=json_serial)
        for region in regions:
            self.client = self.session.client('lambda', region_name=region['RegionName'])
            functions = self.client.list_functions()['Functions']
            #print json.dumps(functions, sort_keys=True, indent=2, default=json_serial)
            for function in functions:
                if 'custodian' in function['FunctionName']:
                    print("Deleting lambda function %s in region %s" % (function['FunctionName'], region['RegionName']))
                    if self.dry_run is None:
                        self.client.delete_function(FunctionName=function['FunctionName'])

class config:
    def __init__(self, profile, dry_run):
        self.profile = profile
        self.dry_run = dry_run

        print("Searching for Cloud Custodian Config rules in all regions")
        self.session = boto3.session.Session(profile_name=self.profile, region_name='us-east-1')
        self.ec2 = self.session.client('ec2')
        regions = self.ec2.describe_regions()['Regions']
        #print json.dumps(regions, sort_keys=True, indent=2, default=json_serial)
        for region in regions:
            self.client = self.session.client('config', region_name=region['RegionName'])
            rules = self.client.describe_config_rules()['ConfigRules']
            #print json.dumps(rules, sort_keys=True, indent=2, default=json_serial)
            for rule in rules:
                if 'custodian' in rule['ConfigRuleName']:
                    print("Deleting config rule %s in region %s" % (rule['ConfigRuleName'], region['RegionName']))
                    if self.dry_run is None:
                        self.client.delete_config_rule(ConfigRuleName=rule['ConfigRuleName'])

class logs:
    def __init__(self, profile, dry_run):
        self.profile = profile
        self.dry_run = dry_run

        print("Searching for Cloud Custodian Cloudwatch log groups in all regions")
        self.session = boto3.session.Session(profile_name=self.profile, region_name='us-east-1')
        self.ec2 = self.session.client('ec2')
        regions = self.ec2.describe_regions()['Regions']
        #print json.dumps(regions, sort_keys=True, indent=2, default=json_serial)
        for region in regions:
            self.client = self.session.client('logs', region_name=region['RegionName'])
            loggroups = self.client.describe_log_groups(logGroupNamePrefix='/aws/lambda/')['logGroups']
            #print json.dumps(loggroups, sort_keys=True, indent=2, default=json_serial)
            for loggroup in loggroups:
                if 'custodian' in loggroup['logGroupName']:
                    #print json.dumps(loggroup, sort_keys=True, indent=2, default=json_serial)
                    print("Deleting log group %s" % loggroup['logGroupName'])
                    if self.dry_run is None:
                        self.client.delete_log_group(logGroupName=loggroup['logGroupName'])

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Delete Cloud Custodian")
    parser.add_argument('--profile', default='default')
    parser.add_argument('--dry_run', action='count')
    args = parser.parse_args()
    profile = args.profile
    dry_run = args.dry_run

    awslambda(profile, dry_run)
    config(profile, dry_run)
    logs(profile, dry_run)
