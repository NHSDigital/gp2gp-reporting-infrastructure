REQUIREMENTS_PATH=lambdas/requirements

CORE_REQUIREMENTS=$(REQUIREMENTS_PATH)/requirements.txt
TEST_REQUIREMENTS=$(REQUIREMENTS_PATH)/test_requirements.txt

terraform-format:
	terraform fmt -recursive

env:
	@echo "Removing old venv."
	@rm -rf lambdas/venv || true
	@echo "Building new venv and installing requirements."
	@python3 -m venv ./lambdas/venv
	@./lambdas/venv/bin/pip3 install --upgrade pip
	@./lambdas/venv/bin/pip3 install -r $(CORE_REQUIREMENTS) --no-cache-dir
	@./lambdas/venv/bin/pip3 install -r $(TEST_REQUIREMENTS) --no-cache-dir
	@echo "Now activate your venv."
	@echo AWS_REGION=eu-west-2

test-coverage:
	cd ./lambdas && ./venv/bin/python3 -m pytest tests --cov=. --cov-report xml:coverage.xml