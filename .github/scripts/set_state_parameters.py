import os
import sys
env = sys.argv[1]
project = sys.argv[2]
with open(os.environ['GITHUB_OUTPUT'], 'a') as fh:
    print(f"title_environment={env.title()}", file=fh)
    print(f"project_upper={project.upper()}", file=fh)
    print(f"account_number_secret={project.upper()}_{env.upper()}_ACCOUNT_NUMBER", file=fh)
    if project == "tdr":
        print(f"role_name=TDRGithubTerraformAssumeRole{env.title()}", file=fh)
        print(f"state_bucket=tdr-terraform-state", file=fh)
        print(f"dynamo_table=tdr-terraform-state-lock", file=fh)
        print(f"custodian_role_name=TDRGithubActionsCustodianDeployRole{env.title()}", file=fh)
        print(f"email=tdr-secops@nationalarchives.gov.uk", file=fh)
    elif project == "dr2":
        print(f"role_name=MgmtDPGithubTerraformEnvironmentsRole{env.title()}", file=fh)
        print(f"state_bucket=mgmt-dp-terraform-state", file=fh)
        print(f"dynamo_table=mgmt-dp-terraform-state-lock", file=fh)
