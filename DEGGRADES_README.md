Set-up

To use localstack to deploy the degrades-dashboards stack create a local.auto.tfvars within the terraform directory and add the following variables
environment="dev"
region="eu-west-2"
registrations_mi_event_bucket="bucket"
degrades_message_queue="queue"
degrades_message_table="table"

This isn't necessary but will require manual input if not present

Setting up virtual venv

`make degrades-env`
Install dependencies needed for degrades work

`make test-degrades`
Run python unit tests for degrades work

`make deploy-local`
Deploy degrades infrastructure to local environment using localstack

`make zip-degrades-lambda`
Create zip files of degrades lambdas and dependencies under path => stacks/degrades-dashboards/terraform/lambda/build