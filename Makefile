
all: build/ docs/index.html

build/:
	mkdir -p build

build/%: scripts/%.create
	scripts/$(@F).create

docs/index.html: build/index.html
	cp build/index.html docs/index.html

build/graphdata.jsonnet: insights.py build/rki.csv build/hopkins.csv build/population.csv

build/index.html: build/graphdata.jsonnet index.html.jinja2 graphs.jsonnet build/Chart.min.js build/bootstrap.min.css

.PHONY: clean
clean:
	rm -f build/*

.PHONY: watch
watch:
	while true; do \
	    make; \
	    inotifywait --exclude '/\.' -qre close_write .; \
	done
