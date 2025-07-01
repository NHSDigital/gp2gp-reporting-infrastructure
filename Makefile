BUILD_PATH = stacks/degrades-dashboards/terraform/lambda/build
DEGRADES_LAMBDA_PATH = lambda/degrades-dashboards

degrades-env:
	cd $(DEGRADES_LAMBDA_PATH) && rm -rf lambdas/venv || true
	cd $(DEGRADES_LAMBDA_PATH) && python3 -m venv ./venv
	cd $(DEGRADES_LAMBDA_PATH) && ./venv/bin/pip3 install --upgrade pip
	cd $(DEGRADES_LAMBDA_PATH) && ./venv/bin/pip3 install -r requirements.txt --no-cache-dir
	cd $(DEGRADES_LAMBDA_PATH) && ./venv/bin/pip3 install -r requirements_local.txt --no-cache-dir


test-degrades:
	cd $(DEGRADES_LAMBDA_PATH)  && venv/bin/python3 -m pytest tests/

zip-lambda-layer:
	cd $(DEGRADES_LAMBDA_PATH) && rm -rf ../../$(BUILD_PATH) || true
	cd $(DEGRADES_LAMBDA_PATH) && mkdir -p ../../$(BUILD_PATH)/layers
	cd $(DEGRADES_LAMBDA_PATH) && ./venv/bin/pip3 install --platform manylinux2014_x86_64 --only-binary=:all: --implementation cp --python-version 3.12 -r requirements.txt -t ../../$(BUILD_PATH)/layers
	cd $(BUILD_PATH)/layers && zip -r -X ../degrades-lambda-layer.zip .


deploy-local:  zip-degrades-lambdas
	ACTIVATE_PRO=0 localstack start -d
	$(DEGRADES_LAMBDA_PATH)/venv/bin/awslocal s3 mb s3://terraform-state
	cd stacks/degrades-dashboards/terraform && ../../../$(DEGRADES_LAMBDA_PATH)/venv/bin/tflocal init

	cd stacks/degrades-dashboards/terraform && ../../../$(DEGRADES_LAMBDA_PATH)/venv/bin/tflocal plan
	cd stacks/degrades-dashboards/terraform && ../../../$(DEGRADES_LAMBDA_PATH)/venv/bin/tflocal apply --auto-approve


zip-degrades-lambdas: zip-lambda-layer
	cd $(DEGRADES_LAMBDA_PATH) && mkdir -p ../../$(BUILD_PATH)/degrades-api
	cd $(DEGRADES_LAMBDA_PATH) && mkdir -p ../../$(BUILD_PATH)/degrades-receiver

	cp ./$(DEGRADES_LAMBDA_PATH)/degrades_api_dashboards/main.py $(BUILD_PATH)/degrades-api/
	cp ./$(DEGRADES_LAMBDA_PATH)/degrades_message_receiver/main.py $(BUILD_PATH)/degrades-receiver

	cp -r $(DEGRADES_LAMBDA_PATH)/utils $(BUILD_PATH)/degrades-api/utils
	cp -r $(DEGRADES_LAMBDA_PATH)/utils $(BUILD_PATH)/degrades-receiver/utils


	cp -r $(DEGRADES_LAMBDA_PATH)/models $(BUILD_PATH)/degrades-api/models
	cp -r $(DEGRADES_LAMBDA_PATH)/models $(BUILD_PATH)/degrades-receiver/models


	cd $(BUILD_PATH)/degrades-receiver && zip -r -X ../degrades-message-receiver.zip .
	cd $(BUILD_PATH)/degrades-api && zip -r -X ../degrades-api-dashboards.zip .



