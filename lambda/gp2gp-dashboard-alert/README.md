# gp2gp-dashboard-alert

## Purpose of the lambda

The `gp2gp-dashboard-alert` lambda is used within the `dashboard-pipeline` state machine and is invoked
when there is a failure inside any of the step functions such as the:

- MetricsCalculator ECS task
- ValidateMetrics Lambda
- GP2GP Dashboard Build And Deploy ECS task

It will then send an alert to a Teams channel (a ticket will be raised for this to be converted to a Slack channel notification).

## Steps involved

When the lambda is triggered the event will contain which kind of failure caused the previous stage in the state machine to fail, these potential error messages are:

1. metricsFailed:
   - If the metrics calculator is unable to run.
2. validationError:
   - If the validation fails during the execution of the ValidateMetrics Lambda.
3. dashboardError:
   - If the GP2GP Dashboard Build And Deploy ECS task fails.

## Manual running process/Testing

The Lambda will require an error to be:

1. If you wish to run the entire 'dashboard-pipeline' state machine then navigate to the state machine in the aws console and select 'Start execution' and input the following JSON with SKIP_METRICS set to false:

    ```json
    {
      "SKIP_METRICS": false,
      "time": "2025-11-01T00:00:00Z"
    }
    ```

2. If you wish to manually trigger the lambda you will have to input the correct catch that would be expected from the  previous stage of the state machine:
    - If you want to see a TaskFailed error reported:

      ```json
      {
        "metricsFailed": {
          "Error": "States.TaskFailed",
          "Cause": "Simulated ECS failure."
        }
      }
      ```

    - If you want to see a validation error reported:

      ```json
      {
        "validationError": {
          "Error": "Lambda.FunctionError",
          "Cause": "Simulated ECS failure."
        }
      }
      ```

    - If you want to see a dashboard error reported:

      ```json
      {
        "dashboardError": {
          "Error": "States.TaskFailed",
          "Cause": "Simulated ECS failure."
        }
      }
      ```
