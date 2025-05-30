#!/bin/bash

set -Eeo pipefail

task="$1"

function build_lambda {
    lambda_name=$1

    build_dir=lambda/build/$lambda_name
    rm -rf $build_dir
    mkdir -p $build_dir

    requirements_file=lambda/$lambda_name/requirements.txt
    if test -f "$requirements_file"; then
        pip install -r $requirements_file -t $build_dir
    fi

    cp lambda/$lambda_name/*.py $build_dir

    pushd $build_dir
    zip -r -X ../$lambda_name.zip .
    popd
}

echo "--- ${task} ---"
case "${task}" in
build-lambdas)
  build_lambda log-alerts-technical-failures-above-threshold
  build_lambda log-alerts-pipeline-error
  build_lambda email-report
  build_lambda validate-metrics
  build_lambda gp2gp-dashboard-alert
  build_lambda degrades_dashboards
;;
*)
  echo "Invalid task: '${task}'"
  exit 1
  ;;
esac

set +e 