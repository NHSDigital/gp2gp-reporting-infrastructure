#!/bin/bash

set -Eeo pipefail

task="$1"

function build_lambda {
    lambda_name=$1

    build_dir=lambdas/build/$lambda_name
    utils_dir=lambdas/$lambda_name/utils
    rm -rf $build_dir
    mkdir -p $build_dir

    requirements_file=lambdas/$lambda_name/requirements.txt
    if test -f "$requirements_file"; then
        pip install -r $requirements_file -t $build_dir
    fi

    cp lambdas/$lambda_name/*.py $build_dir


    if [ -d "$utils_dir" ]; then
      mkdir -p "$build_dir/utils"
      cp "$utils_dir"/*.py "$build_dir/utils/"
    fi

    pushd $build_dir
    zip -r -X ../$lambda_name.zip .
    popd
}

echo "--- ${task} ---"
case "${task}" in
build-lambdas)
  build_lambda log-alerts-technical-failures-above-threshold
  build_lambda log_alerts_pipeline_error
  build_lambda email-report
  build_lambda validate_metrics
  build_lambda gp2gp-dashboard-alert
  build_lambda store-asid-lookup
;;
*)
  echo "Invalid task: '${task}'"
  exit 1
  ;;
esac

set +e 