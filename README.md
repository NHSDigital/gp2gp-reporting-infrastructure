# gp2gp-reporting-infrastructure

## Setup

These instructions assume you are using:

- [aws-vault](https://github.com/99designs/aws-vault) to validate your AWS credentials.
- [dojo](https://github.com/kudulab/dojo) to provide an execution environment

## Applying terraform

Rolling out terraform against each environment is managed by the GoCD pipeline. If you'd like to test it locally, run the following commands:

1. If you haven't already, add your profile to the AWS Vault

    `aws-vault add <profile-name>`

1. Enter the container:

    `aws-vault exec <profile-name> -- dojo`

1. Invoke terraform locally

    ```shell
      ./tasks validate <stack-name> <environment>
      ./tasks plan <stack-name> <environment>
    ```

The stack name denotes the specific stack you would like to validate.
The environment can be `dev` or `prod`.

To run the formatting, run `./tasks format <stack-name> <environment>`

## Troubleshooting

Error: `Too many command line arguments. Did you mean to use -chdir?`

Error: `Invalid length for parameter RoleArn, value: 4, valid range: 20-inf`
You are probably trying to use dev/prod credentials instead of using the common account, which will assume
the role for the other environments.

Error: `Error: Failed to validate installed provider`
The .terraform file is most likely stale/unusable. Try removing the .terraform and trying again:
`rm -rf .terraform`

Error refreshing state: BucketRegionError: incorrect region, the bucket is not in
`make sure the environement is correct when running a task, eg: ./tasks dojo-validate ecs-cluster prod`