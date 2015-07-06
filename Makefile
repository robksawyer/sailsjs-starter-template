REPORTER = spec
MOCHA = ./node_modules/.bin/mocha
SAILS = ./node_modules/.bin/sails
JSHINT = ./node_modules/.bin/jshint
COFFEEJSHINT = ./node_modules/.bin/coffee-jshint
ISTANBUL = ./node_modules/.bin/istanbul
TESTAPP = _testapp

COFFEEJSHINT_GLOBALS = sails,describe,it,after,before,beforeEach,afterEach,User,Passport

ifeq (true,$(COVERAGE))
test: coffeejshint coverage
else
test: coffeejshint base clean
endif

base:
	@echo "+------------------------------------+"
	@echo "| Running mocha tests                |"
	@echo "+------------------------------------+"
	@NODE_ENV=test/bootstrap.test.*,test $(MOCHA) \
	--debug \
	--recursive \
	--require coffee-script/register \
	--timeout 60000 \
	--colors \
	--reporter spec \
	--ui bdd \
	--compilers coffee:coffee-script/register


coveralls:
	@echo "+------------------------------------+"
	@echo "| Running mocha tests with coveralls |"
	@echo "+------------------------------------+"
	@NODE_ENV=test $(ISTANBUL) \
	cover ./node_modules/mocha/bin/_mocha \
	--report lcovonly \
	-- -R $(REPORTER) \
	--recursive && \
	cat ./coverage/lcov.info |\
	 ./node_modules/coveralls/bin/coveralls.js && \
	 rm -rf ./coverage

jshint:
	@echo "+------------------------------------+"
	@echo "| Running linter                     |"
	@echo "+------------------------------------+"
	$(JSHINT) test

coffeejshint:
	@echo "+-------------------------------------------+"
	@echo "| Running coffee linter                     |"
	@echo "+-------------------------------------------+"
	$(COFFEEJSHINT) -o node --globals $(COFFEEJSHINT_GLOBALS) test/*.coffee test/**/*.coffee

clean:
	@echo "+------------------------------------+"
	@echo "| Cleaning up                        |"
	@echo "+------------------------------------+"
	rm -rf $(TESTAPP)
	rm -rf coverage

coverage: coveralls clean

.PHONY: test base coveralls coverage
