NAME=TodoClient

FASTLANE=bundle exec fastlane

DC=docker-compose
DC_P=docker-compose -f docker-compose.pact.yml

.DEFAULT_GOAL := all

stop:
	$(DC) stop
	$(DC_P) stop

clean: stop
	$(DC) down --rmi local --remove-orphans -v
	$(DC) rm --all -f -v
	$(DC_P) down --rmi local --remove-orphans -v
	$(DC_P) rm --all -f -v

install:
	bundle install
	carthage bootstrap --platform iOS --no-use-binaries

lint:
	$(FASTLANE) lint

start_mock: stop
	$(DC) up -d

test_local: start_mock
	$(FASTLANE) test_local

test:
	$(FASTLANE) test

contract_tests: start_mock
	$(FASTLANE) contract_tests

pact_publish: stop
	$(DC_P) run pact_broker_client

pact_verify: stop
	$(DC_P) run pact_broker_proxy

all: clean lint test contract_tests pact_publish pact_verify
