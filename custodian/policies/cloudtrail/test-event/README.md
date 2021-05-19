# Detect Root Login - test event
* In the console, browse to the Lambda function "custodian-root-user-login-detected"
* Create a test event of type Amazon CloudWatch
* Paste in the contents of the JSON file in this directory, replacing all the:
 * `some_account_id` instances with a dummy AWS account ID (12 digits)
 * `some_principal_id` instances with a dummy AWS account ID (12 digits)
* Press Test