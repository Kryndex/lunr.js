
SRC = lib/lunr.js \
	lib/utils.js \
	lib/tokenizer.js \
	lib/pipeline.js \
	lib/vector.js \
	lib/stemmer.js \
	lib/stop_word_filter.js \
	lib/trimmer.js \
	lib/token.js \
	lib/token_set.js \
	lib/token_set_builder.js \
	lib/index.js \
	lib/builder.js \
	lib/match_data.js \
	lib/query.js \
	lib/query_parse_error.js \
	lib/query_lexer.js \
	lib/query_parser.js \

YEAR = $(shell date +%Y)
VERSION = $(shell cat VERSION)

SERVER_PORT ?= 3000
TEST_PORT ?= 32423

DOX ?= ./node_modules/.bin/dox
DOX_TEMPLATE ?= ./node_modules/.bin/dox-template
NODE ?= $(shell which node)
NPM ?= $(shell which npm)
PHANTOMJS ?= ./node_modules/.bin/phantomjs
UGLIFYJS ?= ./node_modules/.bin/uglifyjs
QUNIT ?= ./node_modules/.bin/qunit
MOCHA ?= ./node_modules/.bin/mocha

all: node_modules lunr.js lunr.min.js docs bower.json package.json component.json example

lunr.js: $(SRC)
	cat build/wrapper_start $^ build/wrapper_end | \
	sed "s/@YEAR/${YEAR}/" | \
	sed "s/@VERSION/${VERSION}/" > $@

lunr.min.js: lunr.js
	${UGLIFYJS} --compress --mangle --comments < $< > $@

%.json: build/%.json.template
	cat $< | sed "s/@VERSION/${VERSION}/" > $@

size: lunr.min.js
	@gzip -c lunr.min.js | wc -c

server:
	${NODE} server.js ${SERVER_PORT}

test: node_modules
	@./test/runner.sh ${TEST_PORT}

mocha: lunr.js
	${MOCHA} test/mocha/*.js -u tdd -r test/mocha_helper.js -R dot -C

docs: node_modules
	${DOX} < lunr.js | ${DOX_TEMPLATE} -n lunr.js -r ${VERSION} > docs/index.html

clean:
	rm -f lunr{.min,}.js
	rm *.json
	rm example/example_index.json

reset:
	git checkout lunr.* *.json docs/index.html example/example_index.json

example: lunr.min.js
	${NODE} example/index_builder.js

node_modules: package.json
	${NPM} -s install

.PHONY: test clean docs reset example
