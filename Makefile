.PHONY: tests

build:
	crystal build main.cr

run:
	crystal run main.cr

tests:
	(cd database && make restart)
	crystal run tests/db.cr

py_tests:
	rm database/cristal.db
	touch database/cristal.db
	(cd database && make restart)
	crystal run tests/pypopulate_db.cr
	crystal run main.cr &
	PID=$(echo $$)
	python3 tests/api.py
	stop $(PID)

release:
	crystal build main.cr --no-debug --release --progress

populate:
	(cd database && make restart)
	crystal run tests/populate_db.cr

run_log_db:

help:
