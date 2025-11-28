# Store-Asid-Lookup

## Purpose of the Lambda

On the first day of each month, an email is received from the "DIR team" into the GP2GP mailbox; this email contains an attached CSV file called `asidLookup.csv`, which contains the latest set of active ASID codes.

This file needs:

  1. Zipping.
  2. Storing in S3.
  3. Running against a step function

Which eventually turns it into a file called `organisationMetadata.json` as is stored in S3. This happens automatically each month but in case of a failure, a manual process is required

## Steps involved

1. Email with `asidLookup.csv` attached is sent to {prm asid lookup email address}
2. SES receives the email which:

   a. Stores the file in S3.

   b. Triggers the store-asid-lookup lambda which:
     - Validates the SES event
       - Event source - checks the sender of the mail matches one of the permitted senders.
       - Event destination - the email address it was sent to matches.
     - Obtains the SES email from S3.
     - Extracts the asidLookup.csv attachment.
     - gzips the file.
     - Stores the fine in the 'prm-gp2gp-asid-lookup-{env}' bucket.
     - Triggers the Step Function for the ods-downloader-pipeline, giving input JSON of the first of the current month, and the run title.
     - This will create the `organisationMetadata.json` file and store it in the `prm-gp2gp-ods-metadata{env}` bucket.

## Manual Running process/Testing the Lambda

Before being able to manually test this Lambda you will have to make sure that your email address has been added to the correct SSM parameter.

If the SES/Lambda/Step Function fails:

Once the email is received into the GP2GP mailbox, our tem must (within the first 14 days of a month) follow the instructions below:

- Ask a mailbox owner to forward the email to them.
- Gzip the file:
  - ```gzip asidLookup.csv.gz```
- Manually upload the asidLookup.csv.gz file into s3 - prm-gp2gp-asid-lookup-prod -> YYYY-M
(don't pad the month with a leading 0)
- Start a new execution of the ods-downloader-pipeline State Machine (Step Function) with (make sure to replace Y/M with the appropriate month and year):
  - Name = `YYYY-M`
  - Input:

    ```json
    {
      "time": "YYY-MM-01T00:00:00Z"
    }
    ```

- After ~3m, the job will complete.
- Smoke tests:
  - Check the `prm-gp2gp-ods-metadata-prod` bucket for the presence of `v5/YYY/MM/organisationMetadata.json`.
  - Check the `/aws/lambda/prod-event-enrichment-lambda` Log group to ensure there are no errors.
  - Check the `prod-gp-registrations-mi-events-queue-for-enrichment-dlq` queue for the presence of any messages, - failues should result in messages appearing in the DLQ.
  - Reply to the person who emailed you (step 1) to inform them the file has been actioned.
