ligo_compiler?=docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.51.0
PROTOCOL_OPT?=
JSON_OPT?=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all				- Remove Michelson files, recompile contracts and launch tests'
	@echo  '  all-deploy			- Remove Michelson files, recompile contracts, launch tests and deploy contracts'
	@echo  '  clean				- Remove all generated Michelson files'
	@echo  ''
	@echo  '  compile			- Compile all smart contracts'
	@echo  '  compile_oracle		- Compile smart contract Oracle'
	@echo  '  compile_betting		- Compile smart contract Betting'
	@echo  ''
	@echo  '  test				- Run all integration tests in LIGO'
	@echo  '  test_oracle			- Run integration LIGO tests for Oracle'
	@echo  '  test_betting			- Run integration LIGO tests for Betting'
	@echo  ''
	@echo  '  deploy			- Deploy all smart contracts with Taquito'
	@echo  '  deploy_oracle			- Deploy smart contracts with Taquito for Oracle'
	@echo  '  deploy_betting		- Deploy smart contracts with Taquito for Betting'
	@echo  ''

all: clean compile test

all-deploy: clean compile test deploy

clean:
	@echo "Removing Michelson files..."
	@rm -f src/compiled/*.tz src/compiled/*.json
	@echo "Removing JS deploy files..."
	@rm -f deploy/*.js

# -------------------------
# 		LIGO SECTION
# -------------------------

compile: compile_callback_oracle compile_oracle compile_callback_betting compile_betting

compile_oracle: oracle.tz oracle.json

compile_betting: betting.tz betting.json

compile_callback_oracle: callback_oracle.tz callback_oracle.json

compile_callback_betting: callback_betting.tz callback_betting.json

oracle.tz: src/contracts/jsligo/oracle/main.jsligo
	@if [ ! -d src/compiled ]; then mkdir src/compiled ; fi
	@echo "Compiling Oracle smart contract to Michelson..."
	@$(ligo_compiler) compile contract $^  $(PROTOCOL_OPT) --output-file src/compiled/$@

oracle.json: src/contracts/jsligo/oracle/main.jsligo
	@if [ ! -d src/compiled ]; then mkdir src/compiled ; fi
	@echo "Compiling Oracle smart contract to Michelson in JSON format..."
	@$(ligo_compiler) compile contract $^ $(JSON_OPT)  $(PROTOCOL_OPT) --output-file src/compiled/$@

betting.tz: src/contracts/jsligo/betting/main.jsligo
	@if [ ! -d src/compiled ]; then mkdir src/compiled ; fi
	@echo "Compiling Betting smart contract to Michelson..."
	@$(ligo_compiler) compile contract $^  $(PROTOCOL_OPT) --output-file src/compiled/$@

betting.json: src/contracts/jsligo/betting/main.jsligo
	@if [ ! -d src/compiled ]; then mkdir src/compiled ; fi
	@echo "Compiling Betting smart contract to Michelson in JSON format..."
	@$(ligo_compiler) compile contract $^ $(JSON_OPT)  $(PROTOCOL_OPT) --output-file src/compiled/$@

callback_oracle.tz: src/contracts/jsligo/oracle/callback/main.jsligo
	@if [ ! -d src/compiled ]; then mkdir src/compiled ; fi
	@echo "Compiling callback_Oracle smart contract to Michelson..."
	@$(ligo_compiler) compile contract $^  $(PROTOCOL_OPT) --output-file src/compiled/$@

callback_oracle.json: src/contracts/jsligo/oracle/callback/main.jsligo
	@if [ ! -d src/compiled ]; then mkdir src/compiled ; fi
	@echo "Compiling callback_Oracle smart contract to Michelson in JSON format..."
	@$(ligo_compiler) compile contract $^ $(JSON_OPT)  $(PROTOCOL_OPT) --output-file src/compiled/$@

callback_betting.tz: src/contracts/jsligo/betting/callback/main.jsligo
	@if [ ! -d src/compiled ]; then mkdir src/compiled ; fi
	@echo "Compiling callback_Betting smart contract to Michelson..."
	@$(ligo_compiler) compile contract $^  $(PROTOCOL_OPT) --output-file src/compiled/$@

callback_betting.json: src/contracts/jsligo/betting/callback/main.jsligo
	@if [ ! -d src/compiled ]; then mkdir src/compiled ; fi
	@echo "Compiling callback_Betting smart contract to Michelson in JSON format..."
	@$(ligo_compiler) compile contract $^ $(JSON_OPT)  $(PROTOCOL_OPT) --output-file src/compiled/$@

# -------------------------
# 		TEST SECTION
# -------------------------

test: test_oracle test_betting

test_oracle: test_oracle_manager test_oracle_signer test_oracle_pause test_oracle_events

test_oracle_manager: test/oracle/test.manager.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_oracle_signer: test/oracle/test.signer.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_oracle_pause: test/oracle/test.pause.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_oracle_events: test_oracle_event_add test_oracle_event_update test_oracle_event_get

test_oracle_event_add: test/oracle/test.eventAdd.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_oracle_event_update: test/oracle/test.eventUpdate.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_oracle_event_get: test/oracle/test.eventGet.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_betting: test_betting_manager test_betting_oracle test_betting_pause test_betting_events test_betting_bet

test_betting_manager: test/betting/test.manager.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_betting_oracle: test/betting/test.oracle.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_betting_pause: test/betting/test.pause.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_betting_events: test_betting_event_add test_betting_event_update test_betting_event_get

test_betting_event_add: test/betting/test.eventAdd.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_betting_event_update: test/betting/test.eventUpdate.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_betting_event_get: test/betting/test.eventGet.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_betting_bet: test_betting_bet_add test_betting_bet_finalize

test_betting_bet_add: test/betting/test.betAdd.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_betting_bet_finalize: test/betting/test.betFinalize.jsligo
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

# -------------------------
# 		DEPLOY SECTION
# -------------------------

deploy: install node_modules deploy_oracle deploy_betting
	@echo "Deploying contracts..."

install: deploy/.env.dist
	@if [ ! -f ./deploy/.env ]; then cp ./deploy/.env.dist ./deploy/.env ; fi

node_modules:
	@cd deploy && npm install

deploy_oracle:
	@cd deploy && tsc deploy_oracle --resolveJsonModule -esModuleInterop
	@node deploy/deploy_oracle.js

deploy_betting:
	@cd deploy && tsc deploy_betting --resolveJsonModule -esModuleInterop
	@node deploy/deploy_betting.js

deploy_callback_oracle:
	@cd deploy && tsc deploy_callback_oracle --resolveJsonModule -esModuleInterop
	@node deploy/deploy_callback_oracle.js

deploy_callback_betting:
	@cd deploy && tsc deploy_callback_betting --resolveJsonModule -esModuleInterop
	@node deploy/deploy_callback_betting.js

# -------------------------
#         FLEXTESA
# -------------------------

flextesa-start:
	@./deploy/run-flextesa.sh

flextesa-stop:
	@docker stop flextesa
