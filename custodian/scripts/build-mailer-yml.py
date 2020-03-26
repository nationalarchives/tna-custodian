from pathlib import Path
from ruamel.yaml import YAML
import argparse
import boto3

class mailer:
    def __init__(self, cost_centre, environment, from_address, name, owner, region):
        self.cost_centre = cost_centre
        self.environment = environment
        self.from_address = from_address
        self.name = name
        self.owner = owner
        self.region = region

        path = Path('../custodian/mailer/mailer-template.yml')
        opath = Path('deploy.yml')

        account_id=boto3.client('sts').get_caller_identity().get('Account')

        with YAML(output=opath) as yaml:
            code = yaml.load(path)
            code['queue_url'] = 'https://sqs.' + region + '.amazonaws.com/' + account_id + '/custodian-mailer'
            code['role'] = 'arn:aws:iam::' + account_id + ':role/CustodianMailer'
            code['from_address'] = from_address
            code['region'] = region
            code['lambda_tags'] = dict(CostCentre=cost_centre, Environment=environment, Name=name, Owner=owner)
            yaml.dump(code)

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Build mailer yml")
    parser.add_argument('--cost_centre', required=True)
    parser.add_argument('--environment', required=True)
    parser.add_argument('--from_address', required=True)
    parser.add_argument('--name', default='custodian-mailer')
    parser.add_argument('--owner', required=True)
    parser.add_argument('--region', required=True)

    args = parser.parse_args()

    cost_centre = args.cost_centre
    environment = args.environment
    from_address = args.from_address
    name = args.name
    owner = args.owner
    region = args.region

    mailer(cost_centre, environment, from_address, name, owner, region)