
all: \
	build/ \
	build/bootstrap.min.css \
	build/Chart.min.js \
	build/hopkins.csv \
	build/rki.csv \
	build/population.csv \
	build/graphdata.jsonnet \
	docs/index.html

build/:
	mkdir -p build

build/graphdata.jsonnet: insights.py build/rki.csv build/hopkins.csv build/population.csv
	python3 scripts/graphdata_jsonnet.py

build/bootstrap.min.css:
	wget -P build https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css

build/Chart.min.js:
	wget -P build https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.3/Chart.min.js

build/hopkins.csv:
	python3 scripts/hopkins_csv.py

build/rki.csv:
	python3 scripts/rki_csv.py

build/population.csv:
	python3 scripts/population_csv.py

docs/index.html: index.html.jinja2 build/graphdata.jsonnet graphs.jsonnet build/Chart.min.js build/bootstrap.min.css
	python3 scripts/index_html.py

.PHONY: clean
clean:
	rm -f build/*

watch:
	while true; do \
	    make; \
	    inotifywait --exclude '/\.' -qre close_write .; \
	done
