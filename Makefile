.PHONY: build
build:
	docker-compose build

.PHONY: run
run:
	docker-compose up -d
	timeout --foreground -s SIGKILL 60 bash -c "until docker-compose exec -T search curl http://localhost:9200; do echo waiting-search; sleep 5; done" || exit 1

.PHONY: test
test:
	docker-compose exec -T webapp bundle exec rspec
