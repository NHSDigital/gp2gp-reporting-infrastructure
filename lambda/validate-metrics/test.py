import json
import os
import unittest
from unittest.mock import MagicMock, call, patch

from main import fetch_metrics_from_s3, validate_metrics, _is_valid_national_metrics, \
    InvalidMetrics, _is_valid_practice_metrics

S3_METRICS_BUCKET_NAME = "metrics-bucket"
S3_NATIONAL_METRICS_FILEPATH_PARAM_NAME = "path-to-national-metrics"
S3_PRACTICE_METRICS_FILEPATH_PARAM_NAME = "path-to-practice-metrics"


class TestMain(unittest.TestCase):

    @patch('boto3.client')
    @patch.dict(os.environ, {"S3_METRICS_BUCKET_NAME": S3_METRICS_BUCKET_NAME,
                             "S3_NATIONAL_METRICS_FILEPATH_PARAM_NAME": S3_NATIONAL_METRICS_FILEPATH_PARAM_NAME,
                             "S3_PRACTICE_METRICS_FILEPATH_PARAM_NAME": S3_PRACTICE_METRICS_FILEPATH_PARAM_NAME,
                             "S3_METRICS_VERSION": "v12"})
    def test_fetching_ssm_and_metrics_data_successfully(self, mock_boto_client):
        get_s3_spy = MagicMock()
        get_ssm_spy = MagicMock()
        mock_boto_client("s3").get_object = get_s3_spy
        mock_boto_client("ssm").get_parameter = get_ssm_spy

        result = fetch_metrics_from_s3()

        assert len(result) == 2

        get_ssm_spy.call_count = 2
        get_ssm_spy.assert_has_calls([call(Name="path-to-practice-metrics", WithDecryption=True),
                                      call().__getitem__('Parameter'),
                                      call().__getitem__().__getitem__('Value'),
                                      call(Name="path-to-national-metrics", WithDecryption=True),
                                      call().__getitem__('Parameter'),
                                      call().__getitem__().__getitem__('Value'),
                                      ])
        get_s3_spy.call_count = 2

    @patch('boto3.client')
    @patch.dict(os.environ, {"S3_METRICS_BUCKET_NAME": S3_METRICS_BUCKET_NAME,
                             "S3_NATIONAL_METRICS_FILEPATH_PARAM_NAME": S3_NATIONAL_METRICS_FILEPATH_PARAM_NAME,
                             "S3_PRACTICE_METRICS_FILEPATH_PARAM_NAME": S3_PRACTICE_METRICS_FILEPATH_PARAM_NAME,
                             "S3_METRICS_VERSION": "v12"})
    def test_fetching_metrics_data_successfully_from_s3(self, mock_boto_client):
        get_s3_spy = MagicMock()
        ssm_get_parameter_response_practice = {
            'Parameter': {
                'Value': S3_PRACTICE_METRICS_FILEPATH_PARAM_NAME
            }
        }
        ssm_get_parameter_response_national = {
            'Parameter': {
                'Value': S3_NATIONAL_METRICS_FILEPATH_PARAM_NAME
            }
        }
        mock_boto_client("s3").get_object = get_s3_spy
        mock_boto_client("ssm").get_parameter.side_effect = [ssm_get_parameter_response_practice,
                                                             ssm_get_parameter_response_national]

        result = fetch_metrics_from_s3()

        assert len(result) == 2

        get_s3_spy.assert_has_calls([
            call(Bucket="metrics-bucket", Key="v12/path-to-practice-metrics"),
            call().__getitem__('Body'),
            call().__getitem__().read(),
            call().__getitem__().read().decode(),
            call(Bucket="metrics-bucket", Key="v12/path-to-national-metrics"),
            call().__getitem__('Body'),
            call().__getitem__().read(),
            call().__getitem__().read().decode()])

        get_s3_spy.call_count = 2

    def test_metrics_are_valid(self):
        result = validate_metrics(VALID_PRACTICE_METRICS_JSON, VALID_NATIONAL_METRICS_JSON)
        assert result is True

    def test_throws_invalid_metrics_exception_when_no_ods_codes_for_practice(self):
        practice_metrics_json = json.loads(VALID_PRACTICE_METRICS_JSON)
        wrong_sicbl = json.dumps([
            {
                "odsCode": "10D",
                "name": "Test ICB - 10D",
                "practices": []
            },
            {
                "odsCode": "11D",
                "name": "Another Test ICB - 11D",
                "practices": []
            }
        ])
        practice_metrics_json["sicbls"] = json.loads(wrong_sicbl)
        self.assertRaises(InvalidMetrics, _is_valid_practice_metrics, json.dumps(practice_metrics_json))

    def test_throws_error_when_no_practice_with_6_months_worth_of_data_and_no_ods_code(self):
        self.assertRaises(InvalidMetrics, _is_valid_practice_metrics, INVALID_PRACTICE_METRICS_JSON)

    def test_throws_error_and_interrupts_when_no_practice_with_6_months_worth_of_data(self):
        practice_metrics_json = json.loads(INVALID_PRACTICE_METRICS_JSON)
        # change the generated date to be correct to isolate the no practice error
        practice_metrics_json["generatedOn"] = "2020-01-24T16:51:21.353977",

        self.assertRaises(InvalidMetrics, _is_valid_practice_metrics, json.dumps(practice_metrics_json))

    def test_throws_error_and_interrupts_when_no_practice_with_6_months_worth_of_data_and_no_ods_code(self):
        self.assertRaises(InvalidMetrics, _is_valid_practice_metrics, INVALID_PRACTICE_METRICS_JSON)

    def test_throws_error_when_total_number_of_transfers_less_than_150_000_and_wrong_month_for_national_metrics(
            self):
        self.assertRaises(InvalidMetrics, _is_valid_national_metrics, INVALID_NATIONAL_METRICS_JSON)

    def test_throws_error_and_interrupts_when_month_is_incorrect_for_national_metrics(self):
        national_metrics_json = json.loads(VALID_NATIONAL_METRICS_JSON)
        national_metrics_json["generatedOn"] = "2020-10-24 16:51:21.353977"  # change generation date month
        self.assertRaises(InvalidMetrics, _is_valid_national_metrics, json.dumps(national_metrics_json))

    def test_throws_error_when_total_number_of_transfers_less_than_150_000_for_national_metrics(self):
        national_metrics_json = json.loads(VALID_NATIONAL_METRICS_JSON)
        national_metrics_json["metrics"][0]["transferCount"] = 149_999
        self.assertRaises(InvalidMetrics, _is_valid_national_metrics, json.dumps(national_metrics_json))


VALID_PRACTICE_METRICS_JSON = json.dumps({
    "generatedOn": "2020-02-24 16:51:21.353977",
    "practices": [
        {
            "metrics": [
                {
                    "month": 12,
                    "requestedTransfers": {
                        "requestedCount": 8,
                        "receivedCount": 6,
                        "receivedPercentOfRequested": 75.0,
                        "integratedWithin3DaysCount": 1,
                        "integratedWithin3DaysPercentOfReceived": 16.7,
                        "integratedWithin8DaysCount": 1,
                        "integratedWithin8DaysPercentOfReceived": 16.7,
                        "notIntegratedWithin8DaysPercentOfReceived": 66.7,
                        "notIntegratedWithin8DaysTotal": 4,
                        "failuresTotalCount": 2,
                        "failuresTotalPercentOfRequested": 25.0
                    },
                    "year": 2019
                },
                {
                    "month": 11,
                    "requestedTransfers": {
                        "failuresTotalCount": 0,
                        "failuresTotalPercentOfRequested": 0.0,
                        "integratedWithin3DaysCount": 0,
                        "integratedWithin3DaysPercentOfReceived": 0.0,
                        "integratedWithin8DaysCount": 1,
                        "integratedWithin8DaysPercentOfReceived": 100.0,
                        "notIntegratedWithin8DaysPercentOfReceived": 0.0,
                        "notIntegratedWithin8DaysTotal": 0,
                        "receivedCount": 1,
                        "receivedPercentOfRequested": 100.0,
                        "requestedCount": 1
                    },
                    "year": 2019
                },
                {
                    "month": 10,
                    "requestedTransfers": {
                        "requestedCount": 8,
                        "receivedCount": 6,
                        "receivedPercentOfRequested": 75.0,
                        "integratedWithin3DaysCount": 1,
                        "integratedWithin3DaysPercentOfReceived": 16.7,
                        "integratedWithin8DaysCount": 1,
                        "integratedWithin8DaysPercentOfReceived": 16.7,
                        "notIntegratedWithin8DaysPercentOfReceived": 66.7,
                        "notIntegratedWithin8DaysTotal": 4,
                        "failuresTotalCount": 2,
                        "failuresTotalPercentOfRequested": 25.0
                    },
                    "year": 2019
                },
                {
                    "month": 9,
                    "requestedTransfers": {
                        "requestedCount": 8,
                        "receivedCount": 6,
                        "receivedPercentOfRequested": 75.0,
                        "integratedWithin3DaysCount": 1,
                        "integratedWithin3DaysPercentOfReceived": 16.7,
                        "integratedWithin8DaysCount": 1,
                        "integratedWithin8DaysPercentOfReceived": 16.7,
                        "notIntegratedWithin8DaysPercentOfReceived": 66.7,
                        "notIntegratedWithin8DaysTotal": 4,
                        "failuresTotalCount": 2,
                        "failuresTotalPercentOfRequested": 25.0
                    },
                    "year": 2019
                },
                {
                    "month": 8,
                    "requestedTransfers": {
                        "requestedCount": 8,
                        "receivedCount": 6,
                        "receivedPercentOfRequested": 75.0,
                        "integratedWithin3DaysCount": 1,
                        "integratedWithin3DaysPercentOfReceived": 16.7,
                        "integratedWithin8DaysCount": 1,
                        "integratedWithin8DaysPercentOfReceived": 16.7,
                        "notIntegratedWithin8DaysPercentOfReceived": 66.7,
                        "notIntegratedWithin8DaysTotal": 4,
                        "failuresTotalCount": 2,
                        "failuresTotalPercentOfRequested": 25.0
                    },
                    "year": 2019
                },
                {
                    "month": 7,
                    "requestedTransfers": {
                        "requestedCount": 8,
                        "receivedCount": 6,
                        "receivedPercentOfRequested": 75.0,
                        "integratedWithin3DaysCount": 1,
                        "integratedWithin3DaysPercentOfReceived": 16.7,
                        "integratedWithin8DaysCount": 1,
                        "integratedWithin8DaysPercentOfReceived": 16.7,
                        "notIntegratedWithin8DaysPercentOfReceived": 66.7,
                        "notIntegratedWithin8DaysTotal": 4,
                        "failuresTotalCount": 2,
                        "failuresTotalPercentOfRequested": 25.0
                    },
                    "year": 2019
                },
            ],
            "name": "Test GP Practice with Integrations",
            "odsCode": "A12345",
            "sicblOdsCode": "10D",
            "sicblName": "Test ICB - 10D"
        },
        {
            "metrics": [
                {
                    "month": 12,
                    "requestedTransfers": {
                        "requestedCount": 3,
                        "failuresTotalCount": 1,
                        "failuresTotalPercentOfRequested": 33.3,
                        "integratedWithin3DaysCount": 1,
                        "integratedWithin3DaysPercentOfReceived": 50.0,
                        "integratedWithin8DaysCount": 1,
                        "integratedWithin8DaysPercentOfReceived": 50.0,
                        "notIntegratedWithin8DaysPercentOfReceived": 0.0,
                        "notIntegratedWithin8DaysTotal": 0,
                        "receivedCount": 2,
                        "receivedPercentOfRequested": 66.7
                    },
                    "year": 2019
                },
                {
                    "month": 11,
                    "requestedTransfers": {
                        "failuresTotalCount": 0,
                        "failuresTotalPercentOfRequested": None,
                        "integratedWithin3DaysCount": 0,
                        "integratedWithin3DaysPercentOfReceived": None,
                        "integratedWithin8DaysCount": 0,
                        "integratedWithin8DaysPercentOfReceived": None,
                        "notIntegratedWithin8DaysPercentOfReceived": None,
                        "notIntegratedWithin8DaysTotal": 0,
                        "receivedCount": 0,
                        "receivedPercentOfRequested": None,
                        "requestedCount": 0
                    },
                    "year": 2019
                }
            ],
            "name": "Test GP Practice with some Integrations",
            "odsCode": "A12347",
            "sicblOdsCode": "11D",
            "sicblName": "Another Test ICB - 11D"
        },
        {
            "metrics": [
                {
                    "month": 12,
                    "requestedTransfers": {
                        "requestedCount": 1,
                        "failuresTotalCount": 0,
                        "failuresTotalPercentOfRequested": 0,
                        "integratedWithin3DaysCount": 1,
                        "integratedWithin3DaysPercentOfReceived": 100.0,
                        "integratedWithin8DaysCount": 0,
                        "integratedWithin8DaysPercentOfReceived": 0,
                        "notIntegratedWithin8DaysPercentOfReceived": 0,
                        "notIntegratedWithin8DaysTotal": 0,
                        "receivedCount": 1,
                        "receivedPercentOfRequested": 100.0
                    },
                    "year": 2019
                },
                {
                    "month": 11,
                    "requestedTransfers": {
                        "failuresTotalCount": 0,
                        "failuresTotalPercentOfRequested": None,
                        "integratedWithin3DaysCount": 0,
                        "integratedWithin3DaysPercentOfReceived": None,
                        "integratedWithin8DaysCount": 0,
                        "integratedWithin8DaysPercentOfReceived": None,
                        "notIntegratedWithin8DaysPercentOfReceived": None,
                        "notIntegratedWithin8DaysTotal": 0,
                        "receivedCount": 0,
                        "receivedPercentOfRequested": None,
                        "requestedCount": 0
                    },
                    "year": 2019
                }
            ],
            "name": "Test GP Practice with an Integration",
            "odsCode": "Z12347",
            "sicblOdsCode": "11D",
            "sicblName": "Another Test ICB - 11D"
        }
    ],
    "sicbls": [
        {
            "odsCode": "10D",
            "name": "Test ICB - 10D",
            "practices": [
                "A12345"
            ]
        },
        {
            "odsCode": "11D",
            "name": "Another Test ICB - 11D",
            "practices": [
                "A12347",
                "Z12347"
            ]
        }
    ]
}
)

VALID_NATIONAL_METRICS_JSON = json.dumps({
    "generatedOn": "2020-09-24 16:51:21.353977",
    "metrics": [
        {
            "integratedOnTime": {
                "transferCount": 5,
                "transferPercentage": 41.67
            },
            "month": 8,
            "transferCount": 200_000,
            "year": 2019,
            "paperFallback": {
                "processFailure": {
                    "integratedLate": {
                        "transferCount": 1,
                        "transferPercentage": 8.33
                    },
                    "transferredNotIntegrated": {
                        "transferCount": 3,
                        "transferPercentage": 25.0
                    }
                },
                "technicalFailure": {
                    "transferCount": 2,
                    "transferPercentage": 16.67
                },
                "transferCount": 7,
                "transferPercentage": 58.33,
                "unclassifiedFailure": {
                    "transferCount": 1,
                    "transferPercentage": 8.33
                }
            }
        }
    ]
}
)

# INVALID METRICS
INVALID_PRACTICE_METRICS_JSON = json.dumps({
    "generatedOn": "2020-02-24 16:51:21.353977",
    "practices": [
        {
            "metrics": [
                {
                    "month": 12,
                    "requestedTransfers": {
                        "requestedCount": 8,
                        "receivedCount": 6,
                        "receivedPercentOfRequested": 75.0,
                        "integratedWithin3DaysCount": 1,
                        "integratedWithin3DaysPercentOfReceived": 16.7,
                        "integratedWithin8DaysCount": 1,
                        "integratedWithin8DaysPercentOfReceived": 16.7,
                        "notIntegratedWithin8DaysPercentOfReceived": 66.7,
                        "notIntegratedWithin8DaysTotal": 4,
                        "failuresTotalCount": 2,
                        "failuresTotalPercentOfRequested": 25.0
                    },
                    "year": 2019
                },
                {
                    "month": 11,
                    "requestedTransfers": {
                        "failuresTotalCount": 0,
                        "failuresTotalPercentOfRequested": 0.0,
                        "integratedWithin3DaysCount": 0,
                        "integratedWithin3DaysPercentOfReceived": 0.0,
                        "integratedWithin8DaysCount": 1,
                        "integratedWithin8DaysPercentOfReceived": 100.0,
                        "notIntegratedWithin8DaysPercentOfReceived": 0.0,
                        "notIntegratedWithin8DaysTotal": 0,
                        "receivedCount": 1,
                        "receivedPercentOfRequested": 100.0,
                        "requestedCount": 1
                    },
                    "year": 2019
                }
            ],
            "name": "Test GP Practice with Integrations",
            "odsCode": "A12345",
            "sicblOdsCode": "10D",
            "sicblName": "Test ICB - 10D"
        },
        {
            "metrics": [
                {
                    "month": 12,
                    "requestedTransfers": {
                        "requestedCount": 3,
                        "failuresTotalCount": 1,
                        "failuresTotalPercentOfRequested": 33.3,
                        "integratedWithin3DaysCount": 1,
                        "integratedWithin3DaysPercentOfReceived": 50.0,
                        "integratedWithin8DaysCount": 1,
                        "integratedWithin8DaysPercentOfReceived": 50.0,
                        "notIntegratedWithin8DaysPercentOfReceived": 0.0,
                        "notIntegratedWithin8DaysTotal": 0,
                        "receivedCount": 2,
                        "receivedPercentOfRequested": 66.7
                    },
                    "year": 2019
                },
                {
                    "month": 11,
                    "requestedTransfers": {
                        "failuresTotalCount": 0,
                        "failuresTotalPercentOfRequested": None,
                        "integratedWithin3DaysCount": 0,
                        "integratedWithin3DaysPercentOfReceived": None,
                        "integratedWithin8DaysCount": 0,
                        "integratedWithin8DaysPercentOfReceived": None,
                        "notIntegratedWithin8DaysPercentOfReceived": None,
                        "notIntegratedWithin8DaysTotal": 0,
                        "receivedCount": 0,
                        "receivedPercentOfRequested": None,
                        "requestedCount": 0
                    },
                    "year": 2019
                }
            ],
            "name": "Test GP Practice with some Integrations",
            "odsCode": "A12347",
            "sicblOdsCode": "11D",
            "sicblName": "Another Test ICB - 11D"
        },
        {
            "metrics": [
                {
                    "month": 12,
                    "requestedTransfers": {
                        "requestedCount": 1,
                        "failuresTotalCount": 0,
                        "failuresTotalPercentOfRequested": 0,
                        "integratedWithin3DaysCount": 1,
                        "integratedWithin3DaysPercentOfReceived": 100.0,
                        "integratedWithin8DaysCount": 0,
                        "integratedWithin8DaysPercentOfReceived": 0,
                        "notIntegratedWithin8DaysPercentOfReceived": 0,
                        "notIntegratedWithin8DaysTotal": 0,
                        "receivedCount": 1,
                        "receivedPercentOfRequested": 100.0
                    },
                    "year": 2019
                },
                {
                    "month": 11,
                    "requestedTransfers": {
                        "failuresTotalCount": 0,
                        "failuresTotalPercentOfRequested": None,
                        "integratedWithin3DaysCount": 0,
                        "integratedWithin3DaysPercentOfReceived": None,
                        "integratedWithin8DaysCount": 0,
                        "integratedWithin8DaysPercentOfReceived": None,
                        "notIntegratedWithin8DaysPercentOfReceived": None,
                        "notIntegratedWithin8DaysTotal": 0,
                        "receivedCount": 0,
                        "receivedPercentOfRequested": None,
                        "requestedCount": 0
                    },
                    "year": 2019
                }
            ],
            "name": "Test GP Practice with an Integration",
            "odsCode": "Z12347",
            "sicblOdsCode": "11D",
            "sicblName": "Another Test ICB - 11D"
        }
    ],
    "sicbls": [
        {
            "odsCode": "10D",
            "name": "Test ICB - 10D",
            "practices": [
            ]
        },
        {
            "odsCode": "11D",
            "name": "Another Test ICB - 11D",
            "practices": [
            ]
        }
    ]
}
)

INVALID_NATIONAL_METRICS_JSON = json.dumps({
    "generatedOn": "2020-02-24T16:51:21.353977",
    "metrics": [
        {
            "integratedOnTime": {
                "transferCount": 12,
                "transferPercentage": 41.67
            },
            "month": 12,
            "transferCount": 12,
            "year": 2019,
            "paperFallback": {
                "processFailure": {
                    "integratedLate": {
                        "transferCount": 1,
                        "transferPercentage": 8.33
                    },
                    "transferredNotIntegrated": {
                        "transferCount": 3,
                        "transferPercentage": 25.0
                    }
                },
                "technicalFailure": {
                    "transferCount": 2,
                    "transferPercentage": 16.67
                },
                "transferCount": 7,
                "transferPercentage": 58.33,
                "unclassifiedFailure": {
                    "transferCount": 1,
                    "transferPercentage": 8.33
                }
            }
        }
    ]
}
)
