import os
import sys

env = sys.argv[1]
project = sys.argv[2]
with open(os.environ['GITHUB_OUTPUT'], 'a') as fh:
    print(f"project-upper={project.upper()}", file=fh)
    if project == "tdr":
        print(f"role-name=TDRGithubActionsCustodianDeployRole{env.title()}", file=fh)
        print(f"email=tdr-secops@nationalarchives.gov.uk", file=fh)
    elif project == "dr2":
        print(f"role-name={env.title()}DR2GithubActionsCustodianDeployRole", file=fh)
        print(f"email=da_dp_mgmt@nationalarchives.gov.uk", file=fh)
