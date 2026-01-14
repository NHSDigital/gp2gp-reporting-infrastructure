# lambdas/tests/conftest.py
import os
import pytest

@pytest.fixture(autouse=True)
def _lambda_env(monkeypatch):
    monkeypatch.setenv("AWS_DEFAULT_REGION", "eu-west-2")
    monkeypatch.setenv("AWS_REGION", "eu-west-2")
    monkeypatch.setenv("ENVIRONMENT", "dev")
    monkeypatch.setenv("EMAIL_USER", "test-user")
@pytest.fixture(autouse=True)
def _aws_region_env(monkeypatch):
    # boto3 will accept either of these
    monkeypatch.setenv("AWS_DEFAULT_REGION", "eu-west-2")
    monkeypatch.setenv("AWS_REGION", "eu-west-2")
