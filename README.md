# FIFA WORLD CUP 2018

This should now be working for the World Cup in 2018!  
Should have all events and goals and match stats streaming live, please file an issue or hit me up on twitter @mutualarisisg if anything has gone awry.

https://worldcup.sfg.io  
(HTTPS working for default domain now :yay:)

Special thanks to my employer [Software For Good](https://softwareforgood.com/) for encouraging me to make this as a new programmer 4 years ago and then encourage me to update it for this year (and hosting it!) Encourage your employee's side projects - they learn things!

Main response endpoint:
https://worldcup.sfg.io/matches/today


### Updates

Fixed the simultaneous match issues that cropped up. Found a FIFA JSON API and starting to parse that for some info, if reliable, I'll probably use that for everything as it's way quicker and more reliable than scraping HTML. And next time, we'll all use that one :) Added starting 11 and subs and tactics and also more match information (stage name, weather, officials). Will update the example responses tmrw, but you can check it and see!

More updates at the end of the README

### Caveat Emptor

Note: FIFA is now using much more JS that they were 4 years ago to hide and show information. I'll try to make sure as the tournament goes on that things like penalties are showing up correctly. As always, this runs on a scraper. Changes to HTML structure or banning the IP address it is scraping from could break it at any time. PRs welcome.

## ABOUT

This is a simple backend for a scraper that grabs current world cup results and outputs them as JSON. UPDATE 8 Jun 2015 - This is now working for the Women's World Cup. UPDATE 14 June 2018 - Updated for the World Cup in 2018 with 7 hours to spare!

## SETUP

* Clone the repo

* ```rake db:setup setup:generate_teams``` to initialize the database and generate the teams

* Run the following three tasks as cron jobs (there are also one off scraper jobs you can hit in the `Scrapers::ScraperTasks` file at `lib/scrapers`)

  every short_time, `rake scraper:run_scraper`

  every hour_or_two, `rake scraper:hourly_cleanup`

  every day, `rake scraper:nightly_cleanup`

* If you are setting up mid-tournament you'll need to run the following ScraperTasks: `scrape_old_matches`, `scrape_future_matches`, `scrape_for_stats`, `scrape_for_events`

NOTE: The old scrapers are still there (`lib\tasks\match_scraper.rake`) but the new code is more memory efficient, does some error checking and cleaning up, doesn't break goals and events into two separate scrapes, and is greatly preferred

## RATE LIMITING

The current rate limit is 10 requests every 60 seconds. This is open to change at anytime depending on load, but I'll always keep it so a few requests can fire off in parallel. Please keep your polling down to once a minute or so, 30 seconds if you are feeling greedy, you're not going to get updated information any quicker than that.

## ENDPOINTS

`[url]/teams/` for a list of teams with group ID and FIFA code

`[url]/matches/`
for all matches (Example JSON object at the bottom of this README)

`[url]/teams/results` results for each team (wins, losses, points, goals_for, goals_away, games_played)

`[url]/teams/group_results` results for each group, teams ordered by current groups standings (more or less, not all head to head logic is programmed in as tiebreakers) - can also pass in `?group_id=B` to limit to a specific group.

## OTHER ENDPOINTS

```
[url]/matches/today/
[url]/matches/tomorrow/
[url]/matches/current/
```


You can also retrieve the matches for any team if you know their FIFA code (get fifa code from teams endpoint) by passing it in as a param.

    Example: [url]/matches/country?fifa_code=ISL

## Other Params
  * You can append a start date or a start date and and end date to get the matches for those dates. Example `/matches?start_date=2018-06-19&end_date=2018-06-21` Please use YYYY-MM-DD as your param. `end_date` is optional.

  * You can append `?callback=foo` to get a JSONP response

    Example: `https://worldcup.sfg.io/matches/today?callback=bar`

  * You can append `?by_date=desc` to any query to sort the matches by furthest in the future to furthest in the past. `?by_date=asc` does past to future. (ASC is default sort with no params)

    Example:`[url]/matches/today/?by_date=DESC`

You can also use the by param to get some other sortings of the match list.

  * `total_goals` will sort matches with the largest number of total goals to the least
  * `home_team_goals` will sort matches with the largest number of home team goals to the least
  * `away_team_goals` will sort matches with the largest number of away team goals to the least
  * `closest_scores` will sort matches with draws first to largest winning margin

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

#### MATCH API ENDPOINT

```json
{
  "venue": "Saransk",
  "location": "Mordovia Arena",
  "status": "completed",
  "time": "full-time",
  "fifa_id": "300331550",
  "datetime": "2018-06-19T12:00:00Z",
  "last_event_update_at": "2018-06-19T13:54:02Z",
  "last_score_update_at": "2018-06-19T13:52:45Z",
  "home_team": {
    "country": "Colombia",
    "code": "COL",
    "goals": 1
  },
  "away_team": {
    "country": "Japan",
    "code": "JPN",
    "goals": 2
  },
  "winner": "Japan",
  "winner_code": "JPN",
  "home_team_statistics": {
    "attempts_on_goal": 8,
    "on_target": 3,
    "off_target": 1,
    "blocked": 4,
    "woodwork": 0,
    "corners": 3,
    "offsides": 2,
    "ball_possession": 42,
    "pass_accuracy": 78,
    "num_passes": 363,
    "passes_completed": 284,
    "distance_covered": 93,
    "balls_recovered": 37,
    "tackles": 17,
    "clearances": 20,
    "yellow_cards": 2,
    "red_cards": 1,
    "fouls_committed": 15,
    "country": "Colombia"
  },
  "away_team_statistics": {
    "attempts_on_goal": 14,
    "on_target": 6,
    "off_target": 5,
    "blocked": 3,
    "woodwork": 0,
    "corners": 6,
    "offsides": 1,
    "ball_possession": 58,
    "pass_accuracy": 84,
    "num_passes": 546,
    "passes_completed": 458,
    "distance_covered": 101,
    "balls_recovered": 40,
    "tackles": 15,
    "clearances": 24,
    "yellow_cards": 1,
    "red_cards": 0,
    "fouls_committed": 9,
    "country": "Japan"
  },
  "home_team_events": [
    {
      "id": 203,
      "type_of_event": "red-card",
      "player": "Carlos SANCHEZ",
      "time": "3'"
    },
    {
      "id": 206,
      "type_of_event": "substitution-in",
      "player": "Wilmar BARRIOS",
      "time": "31'"
    },
    {
      "id": 205,
      "type_of_event": "substitution-out",
      "player": "Juan CUADRADO",
      "time": "31'"
    },
    {
      "id": 207,
      "type_of_event": "goal",
      "player": "Juan QUINTERO",
      "time": "39'"
    },
    {
      "id": 209,
      "type_of_event": "substitution-in",
      "player": "James RODRIGUEZ",
      "time": "59'"
    },
    {
      "id": 208,
      "type_of_event": "substitution-out",
      "player": "Juan QUINTERO",
      "time": "59'"
    },
    {
      "id": 210,
      "type_of_event": "yellow-card",
      "player": "Wilmar BARRIOS",
      "time": "64'"
    },
    {
      "id": 212,
      "type_of_event": "substitution-in",
      "player": "Carlos BACCA",
      "time": "70'"
    },
    {
      "id": 211,
      "type_of_event": "substitution-out",
      "player": "Jose IZQUIERDO",
      "time": "70'"
    },
    {
      "id": 220,
      "type_of_event": "yellow-card",
      "player": "James RODRIGUEZ",
      "time": "86'"
    }
  ],
  "away_team_events": [
    {
      "id": 204,
      "type_of_event": "goal-penalty",
      "player": "Shinji KAGAWA",
      "time": "6'"
    },
    {
      "id": 214,
      "type_of_event": "substitution-in",
      "player": "Keisuke HONDA",
      "time": "70'"
    },
    {
      "id": 213,
      "type_of_event": "substitution-out",
      "player": "Shinji KAGAWA",
      "time": "70'"
    },
    {
      "id": 215,
      "type_of_event": "goal",
      "player": "Yuya OSAKO",
      "time": "73'"
    },
    {
      "id": 217,
      "type_of_event": "substitution-in",
      "player": "Hotaru YAMAGUCHI",
      "time": "80'"
    },
    {
      "id": 216,
      "type_of_event": "substitution-out",
      "player": "Gaku SHIBASAKI",
      "time": "80'"
    },
    {
      "id": 219,
      "type_of_event": "substitution-in",
      "player": "Shinji OKAZAKI",
      "time": "85'"
    },
    {
      "id": 218,
      "type_of_event": "substitution-out",
      "player": "Yuya OSAKO",
      "time": "85'"
    },
    {
      "id": 221,
      "type_of_event": "yellow-card",
      "player": "Eiji KAWASHIMA",
      "time": "90'+4'"
    }
  ]
}
```
#### TEAM GROUP RESULTS API ENDPOINT

```json
[
  {
    "group": {
      "id": 1,
      "letter": "A",
      "teams": [
        {
          "team": {
            "id": 1,
            "country": "Russia",
            "fifa_code": "RUS",
            "points": 6,
            "wins": 2,
            "draws": 0,
            "losses": 0,
            "games_played": 2,
            "goals_for": 8,
            "goals_against": 1,
            "goal_differential": 7
          }
        },
        {
          "team": {
            "id": 4,
            "country": "Uruguay",
            "fifa_code": "URU",
            "points": 3,
            "wins": 1,
            "draws": 0,
            "losses": 0,
            "games_played": 1,
            "goals_for": 1,
            "goals_against": 0,
            "goal_differential": 1
          }
        },
        {
          "team": {
            "id": 3,
            "country": "Egypt",
            "fifa_code": "EGY",
            "points": 0,
            "wins": 0,
            "draws": 0,
            "losses": 2,
            "games_played": 2,
            "goals_for": 1,
            "goals_against": 4,
            "goal_differential": -3
          }
        },
        {
          "team": {
            "id": 2,
            "country": "Saudi Arabia",
            "fifa_code": "KSA",
            "points": 0,
            "wins": 0,
            "draws": 0,
            "losses": 1,
            "games_played": 1,
            "goals_for": 0,
            "goals_against": 5,
            "goal_differential": -5
          }
        }
      ]
    }
  }
]
```

## TRY IT OUT (We'll keep this up through the duration of the World Cup)

https://worldcup.sfg.io/matches

https://worldcup.sfg.io/matches/today

https://worldcup.sfg.io/matches/current

https://worldcup.sfg.io/teams/group_results

https://worldcup.sfg.io/teams

## PROJECTS USING THIS API IN 2018

(Feel free to submit a PR with your project!)

* https://m.me/244560172984721 (Facebook Messenger bot that shows games for today and tomorrow as well as allowing you to follow along with live matches)

* https://github.com/jthomas/goalbot   
(Twitter bot ([@WC2018_Goals](https://twitter.com/WC2018_Goals)) which tweets out every goal from the 2018 FIFA World Cup.)  

* https://github.com/justcallmelarry/sportsball   
(slack integration for updates of goals, cards and results)  

* https://github.com/selfish/worldcup-slack  
(Node.js Slack game status announcer, updated for 2018 games)

* https://github.com/dg01d/bitbar-worldcup  
(BitBar plugin to show current/daily scores and results)

* https://github.com/nicolopignatelli/wc2018-slack-bot  
(Slack bot for updates about the current match)

* https://github.com/wildlifehexagon/node-world-cup  
(Node.js command line app to display results and standings)

* https://github.com/iricigor/FIFA2018  
(PowerShell wrapper, compatible with both Linux and Windows versions)

* https://github.com/pedsm/liveCup  
(React.js based dashboard with live updates designed for TVs and Computers)

* https://github.com/johnbfox/world-cup-scores-cli  
(Command line tool for getting the day's scores and goals)

* https://github.com/cedricblondeau/world-cup-2018-cli-dashboard   
(CLI Dashboard that displays live updates of the current game, today's schedule and groups, built with react-blessed)

* https://github.com/sazap10/world-cup-discord-bot  
(Discord bot to display schedule, match information and standings)

* https://github.com/luridarmawan/Carik/  
([Carik](https://github.com/luridarmawan/Carik/) ChatBot for Facebook Messenger, Telegram, Line, Slack. just type "info world cup".) See screenshots [1](https://cl.ly/102h2A1a3S46) [2](https://cl.ly/1p123j342A3v) [3](https://cl.ly/1T0i1E1P410B)

* https://github.com/arghgr/golbot
(Twitter bot that tweets the word GOL, with varying numbers of Os, whenever a goal is scored - [@worldcupgolbot](https://twitter.com/worldcupgolbot))

* https://github.com/kadinho/worldcup-notifications
(A project to fetch FIFA World Cup matches and send Slack event notifications)

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

## BACKGROUND

You can read a blog post about building the API here:
http://softwareforgood.com/soccer-good/

## DONATIONS

Some people have asked if they can make donations. I'd love for you to donate some time writing code or docs or tests, but this is shared totally gratis. If you're interested in throwing some cash someone's way, why not help out organizations working with families separated at the border of the US? At this time of coming together as a human community, let's remember that arbitrary lines on a map still have the power to hurt people.
(https://secure.actblue.com/donate/kidsattheborder)


## UPDATES

### Updates June 19, 2018

* New rate limit -- some of you are really hammering the server. You can now make 10 requests
  every 60 seconds, requests after that will return 429
  with your reset time. Please try to limit polling to once every minute or so and if you are building a SPA please do some cacheing/storing on your side and don't send a request with every user interaction. If you need a whitelist for more requests, please let me know and we can do it, but right now fully half of the requests get throttled and it's a fair amount of load to deal with that many requests coming in more often than 10s apart.

* Better cacheing/fixed broken JSONP cacheing

* Scrapers almost finished being reworked

* New param added to the matches endpoint. You can pass `?start_date=2018-06-21` or `?start_date=2018-06-19&end_date=2018-06-24`  

  (If you pass one date, you'll get matches for that day, otherwise for the range of days specified. Please use YYYY-MM-DD format even though it is weird for the rest of the world not to use YYYY-DD-MM)

### Updates June 18, 2018

* We now retrieve match statistics as well (attempts on goal, saves, etc). This will show up at all the matches endpoints. If you want a more truncated view of a match (no events or stats) please pass `?details=false` to any match endpoint

* You can now retrieve a match by fifa_id if you only want one specific match, just use `/matches/fifa_id/300331499` or as a shortcut just `/matches/300331499`. You'll get a 404 error back if no match has that id.

* Scrapers are being refactored to actually have readable methods, memoize parsed information, etc. Views not calculating anything should increase response time considerably, which is good as we are now at about 30-40 rps.

## WARNING

Removing self deprecating warning. I wrote the best code I could 4 years ago and got it working for the whole Cup, and I'm making it better now. Don't apologize for code you write in a rush to build a cool thing! A bad habit! Just make it better if/when you can.

https://www.linkedin.com/pulse/world-cup-api-take-2-eric-stiens/
