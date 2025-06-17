REQUIREMENTS = requirements_degrades.txt
BUILD_PATH = stacks/degrades-dashboards/terraform/lambda/build

degrades-env:
	rm -rf lambdas/venv || true
	python3 -m venv ./venv
	./venv/bin/pip3 install --upgrade pip
	./venv/bin/pip3 install -r $(REQUIREMENTS) --no-cache-dir


test-degrades:
	cd lambda/degrades-api-dashboards  && ../../venv/bin/python3 -m pytest tests/

deploy-local:  zip-degrades-lambdas
	localstack start -d
	./venv/bin/awslocal s3 mb s3://terraform-state
	cd stacks/degrades-dashboards/terraform && ../../../venv/bin/tflocal init
	cd stacks/degrades-dashboards/terraform && ../../../venv/bin/tflocal plan
	cd stacks/degrades-dashboards/terraform && ../../../venv/bin/tflocal apply --auto-approve

zip-degrades-lambdas:
	rm -rf $(BUILD_PATH) || true
	mkdir -p $(BUILD_PATH)
	./venv/bin/pip3 install -r $(REQUIREMENTS) -t $(BUILD_PATH)/degrades-api
	./venv/bin/pip3 install -r $(REQUIREMENTS) -t $(BUILD_PATH)/degrades-receiver

	cp ./lambda/degrades-api-dashboards/main.py $(BUILD_PATH)/degrades-api/
	cp ./lambda/degrades-api-dashboards/main.py $(BUILD_PATH)/degrades-receiver

	if [ -d "lambda/degrades-api-dashboards/utils" ]; then \
		cp -r lambda/degrades-api-dashboards/utils $(BUILD_PATH)/degrades-api/utils; \
	fi;

	if [ -d "lambda/degrades-message-receiver/utils" ]; then \
		cp -r lambda/degrades-api-dashboards/utils $(BUILD_PATH)/degrades-receiver/utils/; \
	fi;

	cd $(BUILD_PATH)/degrades-receiver && zip -r -X ../degrades-message-receiver.zip .
	cd $(BUILD_PATH)/degrades-api && zip -r -X ../degrades-api-dashboards.zip .


