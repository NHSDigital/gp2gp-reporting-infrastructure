# email-report

## Purpose of the lambda

The purpose of the  email report lambda is to fetch the gp2gp report from the prm-gp2gp-reports-prod S3 bucket,
extract the relevant information, structure and then send an email out to the relevant people

## Steps involved

The lambda is triggered whenever a new report is added to the prm-gp2gp-reports-prod s3 bucket, from the event
the lambda receives the location of the new report and navigates to S3 to grab it. From the reports metadata it
extracts the relevant information such as:

- Reporting window
- Report name
- Cutoff days
- Total technical failures
- Total transfers

it then constructs an email containing all of this information and send it to the relevant people.

For extra context the reports that are generated and added to the S3 bucket are done so by the
reports generator StateMachine.

## Manual running process/Testing

In order to run this lambda manually you will need to trigger it with the following payload. It contains the location
within the prm-gp2gp-reports-dev bucket of an example csv. The csv is blank as this lambda only needs to gather data
from the metadata of the S3 object.

```json
{
    "Records": [
        {
            "s3": {
                "bucket": {
                    "name": "prm-gp2gp-reports-dev",
                    "arn": "arn:aws:s3:::prm-gp2gp-reports-dev"
                },
                "object": {
                    "key": "report_metadata_example.csv"
                }
            }
        }
    ]
}
