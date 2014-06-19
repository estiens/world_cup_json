# ABOUT

This is a simple backend for a scraper that grabs current world cup results and outputs them as JSON.

# SETUP

* Clone the repo

* ```rake db:setup setup:generate_teams``` to initialize the database and generate the teams

* Run the following two tasks as cron jobs, to pull in data with whatever time frame you want (every 5 minutes for example):
```rake fifa:get_group_results``` (This pulls in the standings of the group stages)
```rake fifa:get_all_matches``` (This pulls in all matches and updates any that need updating)

## TODO

* Static landing page
* Add CSS class to determine knocked out teams

## ENDPOINTS

    [url]/teams/
for a list of teams with group ID and FIFA code

    [url]/group_results/
for current results (wins, losses, draws, goals for, goals against, knock out status)

    [url]/matches/
for all matches (Example JSON object at the bottom of this README)

## OTHER ENDPOINTS

    [url]/matches/today/
    [url]/matches/tomorrow/

(what it says on the tin)

You can also retrieve the matches for any team if you know their FIFA code by passing it in as a param.

    Example: [url]/matches/country?fifa_code=USA

## Optional Parameters

You can append `?by_date=desc` to any query tosort the matches by furthest in the future to furthest in the past. `?by_date=asc` does past to future.

    Example:[url]/matches/today/?by_date=DESC

Gives you today's matches in reverse order from latest to earliest.

## EXAMPLE RESPONSES

MATCH API

```json
[
    {
        "match_number": 1,
        "location": "Arena Corinthians",
        "datetime": "2014-06-12T17:00:00.000-03:00",
        "status": "completed",
        "home_team": {
            "country": "Brazil",
            "code": "BRA",
            "goals": 3
        },
        "away_team": {
            "country": "Croatia",
            "code": "CRO",
            "goals": 1
        },
        "winner": "Brazil",

        "home_team_events": [
            {
                "id": 11,
                "type_of_event": "goal-own",
                "player": "Marcelo",
                "time": "11"
            },
            {
                "id": 14,
                "type_of_event": "yellow-card",
                "player": "Neymar Jr",
                "time": "27"
            },
            {
                "id": 15,
                "type_of_event": "goal",
                "player": "Neymar Jr",
                "time": "29"
            },
            {
                "id": 13,
                "type_of_event": "substitution-in",
                "player": "Hernanes",
                "time": "63"
            },
            {
                "id": 12,
                "type_of_event": "substitution-in",
                "player": "Bernard",
                "time": "68"
            },
            {
                "id": 16,
                "type_of_event": "goal-penalty",
                "player": "Neymar Jr",
                "time": "71"
            },
            {
                "id": 19,
                "type_of_event": "yellow-card",
                "player": "L Gustavo",
                "time": "88"
            },
            {
                "id": 17,
                "type_of_event": "substitution-in",
                "player": "Ramires",
                "time": "88"
            },
            {
                "id": 18,
                "type_of_event": "goal",
                "player": "Oscar",
                "time": "901"
            }
            ],
        "away_team_events": [
            {
                "id": 23,
                "type_of_event": "substitution-in",
                "player": "BrozoviĆ",
                "time": "61"
            },
            {
                "id": 20,
                "type_of_event": "yellow-card",
                "player": "Corluka",
                "time": "66"
            },
            {
                "id": 21,
                "type_of_event": "yellow-card",
                "player": "Lovren",
                "time": "69"
            },
            {
                "id": 22,
                "type_of_event": "substitution-in",
                "player": "RebiĆ",
                "time": "78"
            }
        ]
    },
]
```
GROUP RESULTS API

```json
[
    {
        "country": "Brazil",
        "alternate_name": null,
        "fifa_code": "BRA",
        "group_id": 1,
        "wins": 1,
        "draws": 0,
        "losses": 0,
        "goals_for": 3,
        "goals_against": 0,
        "knocked_out": false,
        "updated_at": "2014-06-14T01:06:52.484-05:00"
    }
]
```

## TRY IT OUT (We'll keep this up through the duration of the World Cup)

http://worldcup.sfg.io/matches

http://worldcup.sfg.io/matches/today

http://worldcup.sfg.io/group_results

http://worldcup.sfg.io/teams

## PAGES USING THIS API

http://alexb.ninja/wc

## BACKGROUND

You can read a blog post about building the API here:
http://softwareforgood.com/soccer-good/
