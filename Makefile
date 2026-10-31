SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

# Load local overrides (optional). Command-line variables still win.
-include .env
export

EXAMPLE ?= 01-csv-to-elasticsearch
ELASTIC_VERSION ?= 9.5.5
COMPOSE := docker compose
LOGSTASH_IMAGE := logstash-examples/logstash:$(ELASTIC_VERSION)

.PHONY: help up down reset run validate smoke count kibana

help: ## Show this help
	@awk 'BEGIN {FS = ":.*## "; printf "\nUsage: make <target> [EXAMPLE=...]\n\nTargets:\n"} /^[a-zA-Z_-]+:.*## / {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf "\nExamples:\n"
	@ls -1 examples | sed 's/^/  /'
	@printf "\n"

up: ## Start Elasticsearch, Kibana and PostgreSQL
	$(COMPOSE) up -d elasticsearch kibana postgres
	@printf "Elasticsearch: http://localhost:9200\nKibana:        http://localhost:5601 (ready in ~30s)\n"

down: ## Stop containers (keep indexed data)
	$(COMPOSE) --profile pipeline down

reset: ## Stop containers and delete all demo data
	$(COMPOSE) --profile pipeline down -v

run: ## Run one example, e.g. make run EXAMPLE=03-json-to-elasticsearch
	@test -d "examples/$(EXAMPLE)" || { echo "Unknown example: $(EXAMPLE)"; echo "Run 'make help' to list examples."; exit 1; }
	EXAMPLE=$(EXAMPLE) $(COMPOSE) --profile pipeline run --rm logstash

validate: ## Syntax-check every pipeline inside the Logstash image
	docker build --build-arg ELASTIC_VERSION=$(ELASTIC_VERSION) -t $(LOGSTASH_IMAGE) ./docker/logstash
	@set -euo pipefail; \
	for dir in examples/*/; do \
		printf "\n==> %s\n" "$$dir"; \
		docker run --rm -e LS_JAVA_OPTS="-Xms256m -Xmx256m" \
			-v "$(CURDIR)/$$dir:/example:ro" \
			$(LOGSTASH_IMAGE) \
			bin/logstash --config.test_and_exit -f /example/pipeline/logstash.conf; \
	done

smoke: ## Run examples 01-05 end-to-end and check document counts
	$(COMPOSE) up -d elasticsearch postgres
	@./scripts/smoke-test.sh

count: ## Show document counts for the demo indices
	@curl -fsS 'http://localhost:9200/_cat/indices/demo-*?v&h=index,docs.count'

kibana: ## Create the "Logstash demos" data view in Kibana
	@curl -fsS -X POST 'http://localhost:5601/api/data_views/data_view' \
		-H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
		-d '{"data_view":{"title":"demo-*","name":"Logstash demos","timeFieldName":"@timestamp"}}' \
		&& printf '\nData view created: demo-*\n' \
		|| printf '\nCould not create data view (it may already exist, or Kibana is still starting).\n'
