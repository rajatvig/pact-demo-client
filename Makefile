NAME=TodoClient

RBENV=rbenv exec
BUNDLE=bundle exec
FASTLANE=$(BUNDLE) fastlane

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
	$(RBENV) $(BUNDLE) install
	$(RBENV) $(BUNDLE) pod install

lint:
	$(FASTLANE) lint

test_local: stop
	$(DC) up -d
	$(FASTLANE) test_local

test:
	$(FASTLANE) test

contract_tests: stop
	$(DC) up -d
	$(FASTLANE) contract_tests
	$(DC) stop

pact_publish:
	$(DC_P) run pactbroker_client

pact_verify:
	$(DC_P) run pact_broker_proxy

all: clean lint test contract_tests pact_publish pact_verify
