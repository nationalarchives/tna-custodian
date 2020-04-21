# guard-duty-notify

## TEST
* create a test event for the custodian-guard-duty-notify lambda function
* copy the contents of crypto-test-event.json into the test event template
* replace the Account ID and Guard Duty detector ID with real values
* create an EC2 instance in the same region as the GuardDuty master account
* replace the instance ID in the test event with the real instance ID
* test the lambda function using the newly created test event
