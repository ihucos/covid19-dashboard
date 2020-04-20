
all: build/ index.html

build/:
	mkdir -p build

build/%: scripts/%.create
	scripts/$(@F).create

index.html: build/index.html
	cp build/index.html index.html

build/graphdata.jsonnet: insights.py build/rki.csv build/hopkins.csv build/population.csv build/rki_age.csv

build/index.html: build/graphdata.jsonnet index.html.jinja2 graphs.jsonnet build/Chart.min.js build/bootstrap.min.css

.PHONY: clean
clean:
	rm -f build/*

.PHONY: watch
watch:
	while true; do \
	    printf '\n\n'; \
	    make; \
	    inotifywait --exclude '/\.' -qqre close_write .; \
	done
