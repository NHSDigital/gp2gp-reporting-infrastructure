from datetime import datetime
from typing import Callable


def validate_date_input(lambda_func: Callable):

    def interceptor(event, context):

        try:
            params = event.get("queryStringParameters", None)
            if not params:
                return {"statusCode": 400}

            string_date = params.get("date", None)
            if not string_date:
                return {"statusCode": 400}

            datetime.strptime(string_date, "%Y-%m-%d").date()

            return lambda_func(event, context)

        except ValueError:
            return {"statusCode": 400}

    return interceptor