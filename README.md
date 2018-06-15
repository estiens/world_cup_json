# FIFA WORLD CUP 2018

This should be now working for the World Cup in 2018! (Okay, now really working aside from zone minor time zone issues. Should have all events and goals streaming live, please file an issue if you notice any.)
http://worldcup.sfg.io

--

Main response endpoint:
http://worldcup.sfg.io/matches/today

If you need SSL access, please use
https://world-cup-json.herokuapp.com 
for the time being until SSL is working on the main domain

--

Note: FIFA is now using much more JS that they were 4 years ago to hide and show information. I'll try to make sure as the tournament goes on that things like penalties are showing up correctly. As always, this runs on a scraper. Changes to HTML structure or banning the IP address it is scraping from could break it at any time. PRs welcome.

FIFA has changed their HTML structure from all previous tournaments. I can surmise how all results and goals show up, but I'm not yet sure about events (cards, subs, etc). I will try to have this working within 24 hours of the first match being played, and add any extra information they are displaying this time.

# ABOUT

This is a simple backend for a scraper that grabs current world cup results and outputs them as JSON. UPDATE 8 Jun 2015 - This is now working for the Women's World Cup. UPDATE 14 June 2018 - Updated for the World Cup in 2018 with 7 hours to spare!

# SETUP

* Clone the repo

* ```rake db:setup setup:generate_teams``` to initialize the database and generate the teams

* Run the following two tasks as cron jobs, to pull in data with whatever time frame you want (every 5 minutes for example)

```rake fifa:get_all_matches``` (This pulls in all matches and updates any that need updating with current score)

```rake fifa:get_events``` (This scans for events - goals, substitutions, and cards, and updates the match data accordingly)

## ENDPOINTS

    [url]/teams/
for a list of teams with group ID and FIFA code

-

    [url]/matches/
for all matches (Example JSON object at the bottom of this README)

-

    [url]/teams/results
results for each team (wins, losses, points, goals_for, goals_away, games_played)

-

    [url]/teams/group_results
results for each group, teams ordered by current groups standings. Includes group letter, team, points, and goal differential

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
        "venue":  "Brazil",
        "location": "Arena Corinthians",
        "datetime": "2014-06-12T17:00:00.000-03:00",
        "status": "in progress",
	"time": "halftime",
	"last_score_update_at": "2018-06-15T19:01:58.773Z",
	"last_event_update_at": "2018-06-15T19:01:58.773Z",
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
TEAM GROUP RESULTS API

```json
[{"id":1,"country":"Russia","alternate_name":null,"fifa_code":"RUS","group_id":1,"group_letter":"A","wins":1,"draws":0,"losses":0,"games_played":1,"points":3,"goals_for":5,"goals_against":0,"goal_differential":5}...
```

## TRY IT OUT (We'll keep this up through the duration of the World Cup)

http://worldcup.sfg.io/matches

http://worldcup.sfg.io/matches/today

http://worldcup.sfg.io/matches/current

http://worldcup.sfg.io/teams/group_results

http://worldcup.sfg.io/teams

## PROJECTS USING THIS API IN 2018

(Feel free to submit a PR with your project!)

https://github.com/justcallmelarry/sportsball (slack integration for updates of goals, cards and results)

## PROJECTS USING THIS API IN 2014

* http://alexb.ninja/wc

* https://github.com/fatiherikli/worldcup (displays World Cup results in the terminal)

* https://github.com/ColtCarder/XMPP-World-Cup-Bot (Ruby/Blather XMPP Bot to private message live World Cup events as well as overall results.)

* https://github.com/gberger/hubot-world-cup-live (Hubot plugin that pushes World Cup goals to a chat room)

* World Cup SMS updates at http://worldcupsms.herokuapp.com/ by @andyjiang

* https://github.com/brenopolanski/chrome-worldcup2014-extension (World Cup 2014 - Chrome Extension)

* http://worldcup2014.meteor.com/ - betting pool app for @q42 built by @primigenus using @meteor

* https://github.com/Friss/WorldCup - World Cup matches with the arena in the background

* https://github.com/sestaton/WorldCupStats - World Cup stats and match information at the command line

* https://github.com/selfish/worldcup-slack - A slack game status announcer, updated for 2018 games

## BACKGROUND

You can read a blog post about building the API here:
http://softwareforgood.com/soccer-good/

## WARNING

Most of this was written in a rush 4 years ago, and the rest was written in a rush on day 1 of the World Cup in 2018 to adjust for the new FIFA CMS and live updates via JS. This is not good object oriented code. Scraping is inherently a messy and brittle procedural process. I may try to refactor, but my primary goal was the get something functional. Please do not use as an example of good Rails code!

