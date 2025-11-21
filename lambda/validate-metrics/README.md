# Validate Metrics

## Purpose of the Lambda
The validate metrics lambda is called via the Metrics calculater task within the dashboard-pipeline statemachine after 
MetricsCalculator ECS task has been run.




## Steps involved

1. The metrics for all practices and the national metrics are fetched from an S3 bucket (prm-gp2gp-metrics-{env})
2. Validates the two sets of metrics via:
   - _is_valid_practice_metrics which:
     - Loads the practise_metrics json and breaks out the list of SICBLS (Sub ICB Locations) and a list of all of the
     practices.
     - Checks that there is at least one SICBL's and it contains practices.
     - Checks that at least one practice exists with an ODS code and 6 months worth of metrics, including the latest month.
   
   - _is_valid_national_metrics
     - Extracts the transfer count from the national_metrics_json and logs out the total count
     - Extracts the month that the metrics were generated and logs those out.
     - Validates that the total transfer count is not less than the 'minimum number of expected transfer threshold' (150,000)
     and that the data is for the correct month.
3. If both metrics are valid then a True response is returned and the Statemachine moves onto it's next stage (gp2gp-Dashboard-build-and-deploy)
4. If one or more of the metrics are invalid then an exception is raised, and upon the end of the Lambdas execution
 the StateMachine moves onto the next stage and invokes the GP2GP-Dashboard-Alert Lambda with a FAILED flag and will report the errors.


## Manual running process / Testing

1. The Lambda itself can be manually triggered in the AWS console.
2. If you wish to run the entire 'dashboard-pipeline' state machine then navigate to the state machine in the aws console
and select 'Start execution' and input the following JSON with SKIP_METRICS set to false:
    ```json
    {
      "SKIP_METRICS": false,
      "time": "2025-11-01T00:00:00Z"
    }
   ```
