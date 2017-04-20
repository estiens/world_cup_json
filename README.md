# ABOUT

This is a simple backend for a scraper that grabs current world cup results and outputs them as JSON. UPDATE 8 Jun 2015 - This is now working for the Women's World Cup.

# SETUP

* Clone the repo

* ```rake db:setup setup:generate_teams``` to initialize the database and generate the teams

* Run the following two tasks as cron jobs, to pull in data with whatever time frame you want (every 5 minutes for example)

```rake fifa:get_all_matches``` (This pulls in all matches and updates any that need updating)

```rake fifa:get_all_events``` (This scans for events - goals, substitutions, and cards, and updates the match data accordingly)

## ENDPOINTS

    [url]/teams/
for a list of teams with group ID and FIFA code

~~[url]/group_results/~~
~~for current results (wins, losses, draws, goals for, goals against, knock out status)~~
(this will still run through the group stages, but it has been depricated in favor of the more comprehensive endpoints below)

    [url]/matches/
for all matches (Example JSON object at the bottom of this README)

    [url]/teams/results
results for each team (wins, losses, points, goals_for, goals_away, games_played) *(replaces `[url]/group_results` endpoint)*

    [url]/teams/group_results
results for each group, teams ordered by current groups standings. includes group letter, team, points, and goal differential

## OTHER ENDPOINTS

    [url]/matches/today/
    [url]/matches/tomorrow/

(what it says on the tin)

You can also retrieve the matches for any team if you know their FIFA code by passing it in as a param.

    Example: [url]/matches/country?fifa_code=USA

## Optional Parameters

  * You can append `?callback=foo` to get a JSONP response

    Example: `http://worldcup.sfg.io/matches/today?callback=bar`
    
  * You can append `?by_date=desc` to any query tosort the matches by furthest in the future to furthest in the past. `?by_date=asc` does past to future.

    Example:`[url]/matches/today/?by_date=DESC`

You can also use the by param to get some other sortings of the match list.

  * `total_goals` will sort matches with the largest number of total goals to the least
  * `home_team_goals` will sort matches with the largest number of home team goals to the least
  * `away_team_goals` will sort matches with the largest number of away team goals to the least
  * `closest_scores` will sort matches with draws first to largest winning marging

    Example:`[url]/matches/current/?by=closest_scores`

#### JSONP

The API also supports [JSONP](http://en.wikipedia.org/wiki/JSONP) style output via the `callback` parameter, e.g. `[url]/teams/results?callback=processData` responds with

```json
processData(
	[
		{
				"id": 1,
				"country": "Brazil",
				"alternate_name": null,
				"fifa_code": "BRA",
				...
		}
	]
)
```

The response includes the same data output as the regular GET call without parameters, but wrapped inside a function. This can be used to get around cross origin issues.

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

## PROJECTS USING THIS API

* http://alexb.ninja/wc

* https://github.com/fatiherikli/worldcup (displays World Cup results in the terminal)

* https://github.com/ColtCarder/XMPP-World-Cup-Bot (Ruby/Blather XMPP Bot to private message live World Cup events as well as overall results.)

* https://github.com/gberger/hubot-world-cup-live (Hubot plugin that pushes World Cup goals to a chat room)

* World Cup SMS updates at http://worldcupsms.herokuapp.com/ by @andyjiang

* https://github.com/brenopolanski/chrome-worldcup2014-extension (World Cup 2014 - Chrome Extension)

* http://worldcup2014.meteor.com/ - betting pool app for @q42 built by @primigenus using @meteor

* https://github.com/Friss/WorldCup - World Cup matches with the arena in the background

* https://github.com/sestaton/WorldCupStats - World Cup stats and match information at the command line

## BACKGROUND

You can read a blog post about building the API here:
http://softwareforgood.com/soccer-good/
