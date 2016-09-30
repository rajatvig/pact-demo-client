NAME=TodoClient

FASTLANE=bundle exec fastlane

DC=docker-compose
DC_P=docker-compose -f docker-compose.pact.yml

.DEFAULT_GOAL := help

stop: ## Stop all Docker Containers
	$(DC) stop
	$(DC_P) stop

clean: stop ## Clean all Docker Volumes, Networks, Orphan containers
	$(DC) down --rmi local --remove-orphans -v
	$(DC) rm --all -f -v
	$(DC_P) down --rmi local --remove-orphans -v
	$(DC_P) rm --all -f -v

install: ## Install Gems, Carthage
	bundle install
	carthage bootstrap --platform iOS --no-use-binaries

lint: ## Run Lint
	$(FASTLANE) lint

start_mock: stop ## Run the Pact Mock Service
	$(DC) up -d

test_local: start_mock
	$(FASTLANE) test_local

test: ## Run all Unit Tests
	$(FASTLANE) test

contract_tests: start_mock ## Run all Contract Tests
	$(FASTLANE) contract_tests

pact_publish: stop ## Publish Pacts to the Broker
	$(DC_P) run pact_broker_client

pact_verify: stop ## Verify Pact with the Provider
	$(DC_P) run pact_broker_proxy

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
