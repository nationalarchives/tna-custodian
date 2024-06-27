from pathlib import Path
from ruamel.yaml import YAML
import argparse

class policy:
    def __init__(self, cost_centre, environment, filepath, name, owner, slack_webhook, to_address, sqs_region, sqs_account):
        self.cost_centre = cost_centre
        self.environment = environment
        self.filepath = filepath
        self.name = name
        self.owner = owner
        self.slack_webhook = slack_webhook
        self.to_address = to_address
        self.sqs_region = sqs_region
        self.sqs_account = sqs_account

        path = Path(filepath)
        opath = Path('deploy.yml')


        with YAML(output=opath) as yaml:
            code = yaml.load(path)
            yaml.indent(mapping=2, sequence=4, offset=2)
            code['policies'][0]['mode']['tags'] = dict(CostCentre=cost_centre, Environment=environment, Name=name, Owner=owner)
            actions = code['policies'][0]['actions']
            queue_url = f'https://sqs.{sqs_region}.amazonaws.com/{sqs_account}/custodian-mailer'

            for action in [action for action in actions if 'transport' in action]:
                action['transport']['queue'] = queue_url
            email_and_slack_action = len([action for action in actions if 'to' in action]) == 2
            if email_and_slack_action:
                actions[0]['to'][0] = to_address
                actions[1]['to'][1] = slack_webhook
            else:
                actions[0]['to'][1] = slack_webhook


            yaml.dump(code)

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Build policy yml")
    parser.add_argument('--cost_centre', required=True)
    parser.add_argument('--environment', required=True)
    parser.add_argument('--filepath', required=True)
    parser.add_argument('--name', default='custodian-policy')
    parser.add_argument('--owner', required=True)
    parser.add_argument('--slack_webhook', required=True)
    parser.add_argument('--to_address', required=True)
    parser.add_argument('--sqs_region', required=True)
    parser.add_argument('--sqs_account', default="{account_id}")

    args = parser.parse_args()

    cost_centre = args.cost_centre
    environment = args.environment
    filepath = args.filepath
    name = args.name
    owner = args.owner
    slack_webhook = args.slack_webhook
    to_address = args.to_address
    sqs_region = args.sqs_region
    sqs_account = args.sqs_account

    policy(cost_centre, environment, filepath, name, owner, slack_webhook, to_address, sqs_region, sqs_account)
