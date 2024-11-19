import boto3
from dataclasses import dataclass

s3_client = boto3.client('s3')
client = boto3.client('secretsmanager', region_name='eu-west-2')
ssm_client = boto3.client('ssm')
environment =  os.environ["ENVIRONMENT"]

def lambda_handler(event, context):
    # TODO PRMP-1059
    #  take event -> get Records[0] from it
    #  validate records[0] matches the above
    #       if it doesn't, delete it from S3
    #  Extract the attachment (asidLookup.csv).
    #  gzip the file.
    #  Put in file in S3 (s3://prm-gp2gp-asid-lookup-{env}/<YYYY>/<(M)M>/asidLookup.csv.gz).

    email_event = event['Records'][0]

def get_permitted_emails():
    ssm_response = ssm_client.get_parameters("/registrations/dev/data-pipeline/gp2gp-dashboard/permitted-emails")
    return ssm_response.parameter.value

def validate_event(email_event: dict):
    # TODO PRMP-1059
    #  retrieve allowed email addresses from SSM
    #  json-ify the event
    #  validate the event matches the schema


    permitted_email_addresses = get_permitted_emails()


    # =============EXPECTED SCHEMA================
    # ses.mail.source = .*=<allowed value from SSM Parameter>$
    # ses.mail.destination[0] contains asidlookup@mail{env_value}.gp-registrations-data.nhs.uk
    # ses.mail.headers[0].X-SES-Spam-Verdict = PASS
    # ses.mail.headers[0].X-SES-Virus-Verdict = PASS
    # ses.mail.headers[0].X-MS-Has-Attach ???
    # ses.receipt.spamVerdict.status = PASS
    # ses.receipt.virusVerdict.status = PASS
    # ses.receipt.spfVerdict.status = PASS ???
    # ses.receipt.dkimVerdict.status = PASS ???

    schema = {
        "ses": {
            "type": "object",
            "properties": {
                "mail": {
                    "type": "object",
                    "properties": {
                        "source": {
                            "type": "string",
                            "enum": permitted_email_addresses,
                        "destination": {
                            "type": "array",
                            "items": {
                                "type": "string",
                                "pattern": fr"^.*asidlookup@mail{environment}\.gp-registrations-data\.nhs\.uk$"
                            }
                        },
                        "headers": {
                            "type": "array",
                            "items": {
                                "type": "object",
                                "properties": {
                                    "X-SES-Spam-Verdict": {"type": "string", "const": "PASS"},
                                    "X-SES-Virus-Verdict": {"type": "string", "const": "PASS"},
                                    "X-MS-Has-Attach": {"type": "string"} # TODO PRMP-1059 establish what this can be
                                },
                            },
                            "minItems": 1
                        }
                    },
                    "required": ["source", "destination", "headers"]
                },
                "receipt": {
                    "type": "object",
                    "properties": {
                        "spamVerdict": {
                            "type": "object",
                            "properties": {
                                "status": {
                                    "type": "string",
                                    "const": "PASS"
                                }
                            }
                        },
                        "virusVerdict": {
                            "type": "object",
                            "properties": {
                                "status": {
                                    "type": "string",
                                    "const": "PASS"
                                }
                            }
                        },
                        "spfVerdict": {
                            "type": "object",
                            "properties": {
                                "status": {
                                    "type": "string",
                                    "const": "PASS"
                                }
                            }
                        },
                        "dkimVerdict": {
                            "type": "object",
                            "properties": {
                                "status": {
                                    "type": "string",
                                    "const": "PASS"
                                }
                            }
                        }
                    },
                    "required": ["spamVerdict", "virusVerdict", "spfVerdict", "dkimVerdict"]
                }
            },
            "required": ["mail", "receipt"]
        }
    },
        "required": ["ses"]
    }

    email_event_as_json = json.dumps(email_event)

    try:
        validate(instance = email_event_as_json, schema = schema)
        # TODO PRMP-1059 log something here indicating success
    except ValidationError as e:
        # TODO PRMP-1059 log something here indicating failure
