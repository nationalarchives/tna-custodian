# Reference Counter Table Checks

These are a specific set of checks for the "reference counter" dynamodb table.

This is to ensure business continuity for the generation of unique piece reference for transferred records to TNA
and are not a global set of checks. As such they only affect the hosting project of the piece reference service.

See here for details of the piece reference service: [da-reference-generator](https://github.com/nationalarchives/da-reference-generator#readme)

## Deployment

Policies and Terraform are deployed the same as other policies and Terraform in the repo.

## Alerts and Remediations

| AWS SERVICE | RULE NAME                             | CONDITION                                                                        | REMEDIATION |
|-------------|---------------------------------------|----------------------------------------------------------------------------------|-------------|
|  DynamoDb   | Reference-counter-table-kms-key-check | Checks if reference counter table encrypted with specific KMS key.               | None        |
|  DynamoDb   | Reference-counter-table-pitr-check    | Checks that point in time recovery (PITR) is enabled for reference counter table | None        |
