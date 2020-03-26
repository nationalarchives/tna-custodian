from pathlib import Path
from ruamel.yaml import YAML
import argparse

class policy:
    def __init__(self, cost_centre, environment, filepath, name, owner, slack_webhook):
        #self.account_id = account_id
        self.cost_centre = cost_centre
        self.environment = environment
        self.filepath = filepath
        self.name = name
        self.owner = owner
        self.slack_webhook = slack_webhook

        path = Path(filepath)
        opath = Path('deploy.yml')


        with YAML(output=opath) as yaml:
            code = yaml.load(path)
            yaml.indent(mapping=2, sequence=4, offset=2)
            code['policies'][0]['mode']['tags'] = dict(CostCentre=cost_centre, Environment=environment, Name=name, Owner=owner)
            code['policies'][0]['actions'][1]['to'][1] = 'https://hooks.slack.com/services/' + slack_webhook
            yaml.dump(code)

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Build policy yml")
    parser.add_argument('--cost_centre', required=True)
    parser.add_argument('--environment', required=True)
    parser.add_argument('--filepath', required=True)
    parser.add_argument('--name', default='custodian-policy')
    parser.add_argument('--owner', required=True)
    parser.add_argument('--slack_webhook', required=True)

    args = parser.parse_args()

    cost_centre = args.cost_centre
    environment = args.environment
    filepath = args.filepath
    name = args.name
    owner = args.owner
    slack_webhook = args.slack_webhook

    policy(cost_centre, environment, filepath, name, owner, slack_webhook)