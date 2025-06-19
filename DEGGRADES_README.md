Set-up

Setting up virtual venv

`make degrades-env`
Install dependencies needed for degrades work

`make test-degrades`
Run python unit tests for degrades work

`make deploy-local`
Deploy degrades infrastructure to local environment using localstack

`make zip-degrades-lambda`
Create zip files of degrades lambdas and dependencies under path => stacks/degrades-dashboards/terraform/lambda/build