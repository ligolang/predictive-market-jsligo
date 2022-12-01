# Betting Contract

This contract represents a Tezos contract written in JsLIGO in which users can bet on events added by the Admin or an Oracle.

The current implementation of the contract is as follows :

## Structure :
- a `Betting` contract, the main contract
- _(optional)_ a `mock Oracle` contract
- _(optional)_ a `callback` contract for the `Betting`
- _(optional)_ a `callback` contract for the `mock Oracle`

## Storage :
```ts
type storage = {
  manager: address,
  oracle_address: address,
  bet_config: bet_config_type,
  events: map<nat, event_type>,
  events_bets: map<nat, event_bets>,
  events_index: nat,
  metadata: map<string, bytes>
}
```
- `manager` : Manager **account** of the Betting contract
- `oracle_address` : Oracle **contract** allowed to add Events and update them
- `events`, `events_bets`, `events_index` : Events mapped to their info, their attached bets, and the latest index
```ts
type bet_config_type = {
  is_betting_paused: bool,
  is_event_creation_paused: bool,
  min_bet_amount: tez,
  retained_profit_quota: nat
}
```
- `is_betting_paused` : is Betting on Events paused (true), or is it allowed (false)
- `is_event_creation_paused` : is the creation of new Events paused (true), or is it allowed (false)
- `min_bet_amount` : the minimum amount to Bet on an Event in a single transaction
- `retainedProfit` : the quota to be retained from Betting profits (deduced as operating gains to the contract, shown as percentage, theorical max is 100)

## Workflow :

![Workflow](./images/Predictive%20Market%20-%20Flowchart.svg)

1) Deploy the Betting contract with an initial storage
2) The `storage.bet_config.is_betting_paused` and `storage.bet_config.is_event_creation_paused` must have as value `false`
3) Add an Event using the `storage.manager` address
4) Add a Bet to the Event using an address that is not `storage.manager` nor `storage.oracle_address`
5) _(optional)_ Add more bets to the first team or second team on the Event
6) Update the Bet to specify the outcome in `is_draw`, and the winning Team in `is_team_one_win` if it is not a draw, using `storage.manager` or `storage.oracle_address`
7) Finalize the Bet using `storage.manager`

## Initial Storage example :
```ts
let init_bet_config : bet_config_type = {
      is_betting_paused: false,
      is_event_creation_paused: false,
      min_bet_amount: 5 as tez,
      retained_profit_quota: 10 as nat
};

let init_storage : storage = {
      manager: "tz1******************",
      oracle_address: "KT1******************",
      bet_config: init_bet_config,
      events: (Map.empty as map<nat, event_type>),
      events_bets: (Map.empty as map<nat, event_bets>),
      events_index: 0 as nat,
      metadata: (Map.empty as map<string, bytes>)
};
```

### - Compile Betting contract :
- To compile the Betting contract to Michelson code :
```bash
docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:stable compile contract src/contracts/cameligo/betting/main.mligo > src/compiled/betting.tz
```
- To compile the Betting contract to Michelson code in JSON format :
```bash
docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:stable compile contract src/contracts/cameligo/betting/main.mligo --michelson-format json > src/compiled/betting.json
```

### - Compile Betting storage :
- Using `tz1bdTsc3QdAj1935KiMxou6frwdm5RDdssT` as example for `storage.manager`
- Using `KT1KMjSSDxTAUZAb7rgGYx3JF4Yz1cwQpwUi` as example for `storage.oracle_address`
```bash
docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:stable compile storage ./contracts/cameligo/betting/main.mligo '{manager: ("tz1bdTsc3QdAj1935KiMxou6frwdm5RDdssT" as address), oracle_address: ("KT1KMjSSDxTAUZAb7rgGYx3JF4Yz1cwQpwUi" as address), bet_config: {is_betting_paused: false, is_event_creation_paused: false, min_bet_amount: 5 as tez, retained_profit_quota: 10 as nat}, events: (Map.empty as map<nat, TYPES.event_type>), events_bets: (Map.empty as map<nat, TYPES.event_bets>), events_index: 0 as nat, metadata: (Map.empty as map<string, bytes>)}' -e main
```

### - Simulate execution of entrypoints (with ligo compiler) :

- For entrypoint SendValue
```bash
docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:stable run dry-run src/contracts/cameligo/betting/main.mligo 'SendValue()' '37' -e main
```

### - Originate the Betting contract (with tezos-client CLI) :
- Compile the storage into Michelson expression :
- Using `tz1bdTsc3QdAj1935KiMxou6frwdm5RDdssT` as example for `storage.manager`
- Using `KT1KMjSSDxTAUZAb7rgGYx3JF4Yz1cwQpwUi` as example for `storage.oracle_address`
```bash
docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:stable compile storage ./contracts/cameligo/betting/main.mligo '{manager: ("tz1bdTsc3QdAj1935KiMxou6frwdm5RDdssT" as address), oracle_address: ("KT1KMjSSDxTAUZAb7rgGYx3JF4Yz1cwQpwUi" as address), bet_config: {is_betting_paused: false, is_event_creation_paused: false, min_bet_amount: 5 as tez, retained_profit_quota: 10 as nat}, events: (Map.empty as map<nat, TYPES.event_type>), events_bets: (Map.empty as map<nat, TYPES.event_bets>), events_index: 0 as nat; metadata: (Map.empty as map<string, bytes>)}' -e main
```
- This command produces the following Michelson storage :
```lisp
(Pair (Pair (Pair (Pair (Pair False False) 5000000 10) {}) {} 0)
      (Pair "tz1bdTsc3QdAj1935KiMxou6frwdm5RDdssT" {})
      "KT1KMjSSDxTAUZAb7rgGYx3JF4Yz1cwQpwUi")
```
- Deploy with tezos-client CLI using the above Michelson code :
```bash
tezos-client originate contract betting transferring 1 from '$USER_ADDRESS' running 'src/compiled/betting.tz' --init '(Pair (Pair (Pair (Pair (Pair False False) 5000000 10) {}) {} 0)(Pair "tz1bdTsc3QdAj1935KiMxou6frwdm5RDdssT" {})"KT1KMjSSDxTAUZAb7rgGYx3JF4Yz1cwQpwUi")'
```

# Oracle Contract

## Storage :
```ts
type storage = {
  isPaused: bool,
  manager: address,
  signer: address,
  events: map<nat, event_type>,
  events_index: nat,
  metadata: map<string, bytes>
}
```
- `isPaused` : If the creation of events on the contract is paused
- `manager` : Manager **account** of the Betting contract
- `signer` : Signer **contract** allowed to add Events and update them (usually a backend script)
- `events`, `events_index` : Events mapped to their info and the latest index

```ts
type event_type = 
  // @layout:comb 
  {
  name: string,
  videogame: string,
  begin_at: timestamp,
  end_at: timestamp,
  modified_at: timestamp,
  opponents: { team_one: string, team_two: string},
  game_status: game_status
}
```

## Available Entrypoints :

The following entrypoints are available :
- ChangeManager
- ChangeSigner
- SwitchPause
- AddEvent
- GetEvent
- UpdateEvent

For full details, please consult the Oracle contracts in `src/contracts/jsligo/oracle`

## Initial Storage example :

```ts
let store : storage = {
    isPaused: False,
    manager: "tz1******************",
    signer: "tz1******************",
    events: (Map.empty as map<nat, event_type>),
    events_index: 0 as nat
}
```

# - Sample data using a 3rd party API :

It is possible to use an external API to collect sample game data about eSports titles such as CS:GO, DOTA 2, and others.

Some sample requests to get data from a third-party API can be found in the Backend folder. We are using here the API provider : [Pandascore](https://pandascore.co/).

The API access tokens can be requested by creating an account on Pandascore [here](https://app.pandascore.co/signup)

The API reference documentation can be viewed [here](https://developers.pandascore.co/reference)

The scripts can be executed as follows :

```bash
node backend/matches_past.js
node backend/matches_running.js
node backend/matches_upcoming.js
```

The result of the queries will be a JSON file in the Backend folder, which will contain game info.

It is possible to inject this data to the Oracle after formatting manually, or automatically using a signer/broadcaster.
