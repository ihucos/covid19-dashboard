
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

build/%: scripts/%.create
	scripts/$(@F).create

docs/index.html: build/index.html
	cp build/index.html docs/index.html

build/graphdata.jsonnet: insights.py build/rki.csv build/hopkins.csv build/population.csv

docs/index.html: index.html.jinja2 build/graphdata.jsonnet graphs.jsonnet build/Chart.min.js build/bootstrap.min.css

.PHONY: clean
clean:
	rm -f build/*

watch:
	while true; do \
	    make; \
	    inotifywait --exclude '/\.' -qre close_write .; \
	done
