# FIFA WORLD CUP 2022

This is on its way to working for 2022. Even on rails 7 now!
Should have all events and goals and match stats streaming live, please file an issue or hit me up on twitter @mutualarising if anything has gone awry.

https://world-cup-json-2022.fly.dev
(HTTPS working for default domain now :yay:)

Special thanks to my employer [Software For Good](https://softwareforgood.com/) for encouraging me to make this many years ago...

Main response endpoint:
https://world-cup-json-2022.fly.dev/matches/today

## WILL UPDATE HERE WHEN LIVE FOR 2022 ##
(should have made a dif deployment branch for each WC, if I had only thought a decade in advance)

## ABOUT

This is a simple backend for a scraper that grabs current world cup results and outputs them as JSON. UPDATE 8 Jun 2015 - This is now working for the Women's World Cup. UPDATE 14 June 2018 - Updated for the World Cup in 2018 with 7 hours to spare!

## SETUP

### TBD2022

<details><summary>WIP for 2022, old setup here</summary>
* Clone the repo

* ```rake db:setup setup:generate_teams``` to initialize the database and generate the teams

* initial run, run `rake scraper:force_all_new` `rake scraper:force_all_old` `rake scraper:setup_json`

* Run the following three tasks as cron jobs (there are also one off scraper jobs you can hit in the `Scrapers::ScraperTasks` file at `lib/scrapers`)

  every short_time, `rake scraper:run_scraper`

  every hour_or_two, `rake scraper:hourly_cleanup`

  every day, `rake scraper:nightly_cleanup`

* If you are setting up mid-tournament you'll need to run the following ScraperTasks: `scrape_old_matches`, `scrape_future_matches`, `scrape_for_stats`, `scrape_for_events`

* If you have trouble setting up feel free to file a ticket and I or someone cal help. Sorry but things moving fast and more interested in keeping this running well than making it easy to setup at the moment.

NOTE: The old scrapers are still there (`lib\tasks\match_scraper.rake`) but the new code is more memory efficient, does some error checking and cleaning up, doesn't break goals and events into two separate scrapes, and is greatly preferred~~
</details>

## RATE LIMITING

The current rate limit is 10 requests every 60 seconds. This is open to change at anytime depending on load, but I'll always keep it so a few requests can fire off in parallel. Please keep your polling down to once a minute or so, 30 seconds if you are feeling greedy, you're not going to get updated information any quicker than that.

## ENDPOINTS

`[url]/teams/` for a list of teams with group ID and FIFA code

`[url]/matches/`
for all matches (Example JSON object at the bottom of this README)

Note - if you want all matches with all details,you must now pass `?details=true` to this endpoint.
All details will be present by default for endpoints like `matches/today` that return less matches...

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

    Example: `https://world-cup-json-2022.fly.dev/matches/today?callback=bar`

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

<details><summary>#### MATCH API ENDPOINT</summary>

```json
[{
  "venue": "Kazan",
  "location": "Kazan Arena",
  "status": "completed",
  "time": "full-time",
  "fifa_id": "300331532",
  "weather": {
    "humidity": "40",
    "temp_celsius": "28",
    "temp_farenheit": "60",
    "wind_speed": "18",
    "description": "Sunny"
  },
  "attendance": "41835",
  "officials": ["Mark GEIGER", "Joe FLETCHER", "Frank ANDERSON", "Julio BASCUNAN", "Danny MAKKELIE", "Corey ROCKWELL", "Tiago MARTINS", "Artur DIAS", "Christian SCHIEMANN"],
  "stage_name": "First stage",
  "home_team_country": "Korea Republic",
  "away_team_country": "Germany",
  "datetime": "2018-06-27T14:00:00Z",
  "winner": "Korea Republic",
  "winner_code": "KOR",
  "home_team": {
    "country": "Korea Republic",
    "code": "KOR",
    "goals": 2,
    "penalties": 0
  },
  "away_team": {
    "country": "Germany",
    "code": "GER",
    "goals": 0,
    "penalties": 0
  },
  "home_team_events": [{
    "id": 739,
    "type_of_event": "yellow-card",
    "player": "JUNG Wooyoung",
    "time": "9'"
  }, {
    "id": 740,
    "type_of_event": "yellow-card",
    "player": "LEE Jaesung",
    "time": "23'"
  }, {
    "id": 742,
    "type_of_event": "yellow-card",
    "player": "MOON Seonmin",
    "time": "48'"
  }, {
    "id": 744,
    "type_of_event": "substitution-out",
    "player": "KOO Jacheol",
    "time": "56'"
  }, {
    "id": 745,
    "type_of_event": "substitution-in",
    "player": "HWANG Heechan",
    "time": "56'"
  }, {
    "id": 756,
    "type_of_event": "yellow-card",
    "player": "SON Heungmin",
    "time": "65'"
  }, {
    "id": 759,
    "type_of_event": "substitution-out",
    "player": "MOON Seonmin",
    "time": "69'"
  }, {
    "id": 760,
    "type_of_event": "substitution-in",
    "player": "JU Sejong",
    "time": "69'"
  }, {
    "id": 766,
    "type_of_event": "substitution-out",
    "player": "HWANG Heechan",
    "time": "79'"
  }, {
    "id": 767,
    "type_of_event": "substitution-in",
    "player": "GO Yohan",
    "time": "79'"
  }, {
    "id": 774,
    "type_of_event": "goal",
    "player": "KIM Younggwon",
    "time": "90'+3'"
  }, {
    "id": 775,
    "type_of_event": "goal",
    "player": "SON Heungmin",
    "time": "90'+6'"
  }],
  "away_team_events": [{
    "id": 748,
    "type_of_event": "substitution-out",
    "player": "Sami KHEDIRA",
    "time": "58'"
  }, {
    "id": 749,
    "type_of_event": "substitution-in",
    "player": "Mario GOMEZ",
    "time": "58'"
  }, {
    "id": 752,
    "type_of_event": "substitution-out",
    "player": "Leon GORETZKA",
    "time": "63'"
  }, {
    "id": 753,
    "type_of_event": "substitution-in",
    "player": "Thomas MUELLER",
    "time": "63'"
  }, {
    "id": 764,
    "type_of_event": "substitution-out",
    "player": "Jonas HECTOR",
    "time": "78'"
  }, {
    "id": 765,
    "type_of_event": "substitution-in",
    "player": "Julian BRANDT",
    "time": "78'"
  }],
  "home_team_statistics": {
    "country": "Korea Republic",
    "attempts_on_goal": 11,
    "on_target": 5,
    "off_target": 5,
    "blocked": 1,
    "woodwork": 0,
    "corners": 3,
    "offsides": 0,
    "ball_possession": 32,
    "pass_accuracy": 71,
    "num_passes": 252,
    "passes_completed": 180,
    "distance_covered": 117,
    "balls_recovered": 40,
    "tackles": 10,
    "clearances": 39,
    "yellow_cards": 4,
    "red_cards": 0,
    "fouls_committed": 16,
    "tactics": "4-4-2",
    "starting_eleven": [{
      "name": "JO Hyeonwoo",
      "captain": false,
      "shirt_number": 23,
      "position": "Goalie"
    }, {
      "name": "LEE Yong",
      "captain": false,
      "shirt_number": 2,
      "position": "Defender"
    }, {
      "name": "YUN Youngsun",
      "captain": false,
      "shirt_number": 5,
      "position": "Defender"
    }, {
      "name": "SON Heungmin",
      "captain": true,
      "shirt_number": 7,
      "position": "Forward"
    }, {
      "name": "KOO Jacheol",
      "captain": false,
      "shirt_number": 13,
      "position": "Midfield"
    }, {
      "name": "HONG Chul",
      "captain": false,
      "shirt_number": 14,
      "position": "Defender"
    }, {
      "name": "JUNG Wooyoung",
      "captain": false,
      "shirt_number": 15,
      "position": "Midfield"
    }, {
      "name": "LEE Jaesung",
      "captain": false,
      "shirt_number": 17,
      "position": "Midfield"
    }, {
      "name": "MOON Seonmin",
      "captain": false,
      "shirt_number": 18,
      "position": "Midfield"
    }, {
      "name": "KIM Younggwon",
      "captain": false,
      "shirt_number": 19,
      "position": "Defender"
    }, {
      "name": "JANG Hyunsoo",
      "captain": false,
      "shirt_number": 20,
      "position": "Defender"
    }],
    "substitutes": [{
      "name": "KIM Seunggyu",
      "captain": false,
      "shirt_number": 1,
      "position": "Goalie"
    }, {
      "name": "JUNG Seunghyun",
      "captain": false,
      "shirt_number": 3,
      "position": "Defender"
    }, {
      "name": "OH Bansuk",
      "captain": false,
      "shirt_number": 4,
      "position": "Defender"
    }, {
      "name": "PARK Jooho",
      "captain": false,
      "shirt_number": 6,
      "position": "Defender"
    }, {
      "name": "JU Sejong",
      "captain": false,
      "shirt_number": 8,
      "position": "Midfield"
    }, {
      "name": "KIM Shinwook",
      "captain": false,
      "shirt_number": 9,
      "position": "Forward"
    }, {
      "name": "LEE Seungwoo",
      "captain": false,
      "shirt_number": 10,
      "position": "Midfield"
    }, {
      "name": "HWANG Heechan",
      "captain": false,
      "shirt_number": 11,
      "position": "Forward"
    }, {
      "name": "KIM Minwoo",
      "captain": false,
      "shirt_number": 12,
      "position": "Defender"
    }, {
      "name": "KI Sungyueng",
      "captain": false,
      "shirt_number": 16,
      "position": "Midfield"
    }, {
      "name": "KIM Jinhyeon",
      "captain": false,
      "shirt_number": 21,
      "position": "Goalie"
    }, {
      "name": "GO Yohan",
      "captain": false,
      "shirt_number": 22,
      "position": "Defender"
    }]
  },
  "away_team_statistics": {
    "country": "Germany",
    "attempts_on_goal": 26,
    "on_target": 6,
    "off_target": 11,
    "blocked": 9,
    "woodwork": 0,
    "corners": 8,
    "offsides": 1,
    "ball_possession": 68,
    "pass_accuracy": 87,
    "num_passes": 715,
    "passes_completed": 622,
    "distance_covered": 114,
    "balls_recovered": 38,
    "tackles": 9,
    "clearances": 10,
    "yellow_cards": 0,
    "red_cards": 0,
    "fouls_committed": 7,
    "tactics": "4-2-3-1",
    "starting_eleven": [{
      "name": "Manuel NEUER",
      "captain": true,
      "shirt_number": 1,
      "position": "Goalie"
    }, {
      "name": "Jonas HECTOR",
      "captain": false,
      "shirt_number": 3,
      "position": "Defender"
    }, {
      "name": "Mats HUMMELS",
      "captain": false,
      "shirt_number": 5,
      "position": "Defender"
    }, {
      "name": "Sami KHEDIRA",
      "captain": false,
      "shirt_number": 6,
      "position": "Midfield"
    }, {
      "name": "Toni KROOS",
      "captain": false,
      "shirt_number": 8,
      "position": "Midfield"
    }, {
      "name": "Timo WERNER",
      "captain": false,
      "shirt_number": 9,
      "position": "Forward"
    }, {
      "name": "Mesut OEZIL",
      "captain": false,
      "shirt_number": 10,
      "position": "Midfield"
    }, {
      "name": "Marco REUS",
      "captain": false,
      "shirt_number": 11,
      "position": "Forward"
    }, {
      "name": "Leon GORETZKA",
      "captain": false,
      "shirt_number": 14,
      "position": "Midfield"
    }, {
      "name": "Niklas SUELE",
      "captain": false,
      "shirt_number": 15,
      "position": "Defender"
    }, {
      "name": "Joshua KIMMICH",
      "captain": false,
      "shirt_number": 18,
      "position": "Defender"
    }],
    "substitutes": [{
      "name": "Marvin PLATTENHARDT",
      "captain": false,
      "shirt_number": 2,
      "position": "Defender"
    }, {
      "name": "Matthias GINTER",
      "captain": false,
      "shirt_number": 4,
      "position": "Defender"
    }, {
      "name": "Julian DRAXLER",
      "captain": false,
      "shirt_number": 7,
      "position": "Midfield"
    }, {
      "name": "Kevin TRAPP",
      "captain": false,
      "shirt_number": 12,
      "position": "Goalie"
    }, {
      "name": "Thomas MUELLER",
      "captain": false,
      "shirt_number": 13,
      "position": "Midfield"
    }, {
      "name": "Antonio RUEDIGER",
      "captain": false,
      "shirt_number": 16,
      "position": "Defender"
    }, {
      "name": "Sebastian RUDY",
      "captain": false,
      "shirt_number": 19,
      "position": "Midfield"
    }, {
      "name": "Julian BRANDT",
      "captain": false,
      "shirt_number": 20,
      "position": "Midfield"
    }, {
      "name": "Ilkay GUENDOGAN",
      "captain": false,
      "shirt_number": 21,
      "position": "Midfield"
    }, {
      "name": "Marc-Andre TER STEGEN",
      "captain": false,
      "shirt_number": 22,
      "position": "Goalie"
    }, {
      "name": "Mario GOMEZ",
      "captain": false,
      "shirt_number": 23,
      "position": "Forward"
    }, {
      "name": "Jerome BOATENG",
      "captain": false,
      "shirt_number": 17,
      "position": "Defender"
    }]
  },
  "last_event_update_at": "2018-06-27T15:58:47Z",
  "last_score_update_at": "2018-06-27T15:58:47Z"
}]
</summary>
```

## TRY IT OUT (We'll keep this up through the duration of the World Cup)

https://world-cup-json-2022.fly.dev/matches

https://world-cup-json-2022.fly.dev/matches/today

https://world-cup-json-2022.fly.dev/matches/current

~~https://world-cup-json-2022.fly.dev/teams/group_results~~

~~https://world-cup-json-2022.fly.dev/teams~~


## PROJECTS USING THIS API IN 2022
(Feel free to submit a PR with your project!)

## PROJECTS USING THIS API IN 2018

<details><summary>2018 projects submitted</summary>

* http://fifa-worldcup.herokuapp.com
(NodeJS and Express Web App to keep you updated with the FIFA World Cup 2018)

* http://meisam-dodangeh.ir/worldcup (A simple web Page to show today games and games events)
* https://m.me/244560172984721 (Facebook Messenger bot that shows games for today and tomorrow as well as allowing you to follow along with live matches)

* https://github.com/jthomas/goalbot
(Twitter bot ([@WC2018_Goals](https://twitter.com/WC2018_Goals)) which tweets out every goal from the 2018 FIFA World Cup.)
* https://github.com/riceluxs1t/EloSoccerPrediction
(React.js + Django app that shows (live) game data and match outcome predictions using an ELO based Poisson model.)

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

* https://github.com/gk4m/world-cup-scores
(Simple vue.js based app for displaying results from World Cup 2018.)

* https://apps.lametric.com/apps/fifa_world_cup_2018/6624
(Display the latest score of the current match(es), or the recent and next matches on a [LaMetric Time](https://lametric.com) device)

* https://world-cup-basecamp.herokuapp.com/
[Github Link](https://github.com/dskoda1/world-cup-basecamp) - SPA using React/Redux/Material for displaying data from this API

* https://spapas.github.io/wc2018/
(A WC2018 dashboard using vue.js. Source @ https://github.com/spapas/vue-wc2018)

* https://github.com/eeddaann/ElastiCup
(Loads World Cup data into Elasticsearch)
</details>

## PROJECTS USING THIS API IN 2014
<details><summary>Some 2014 projects submitted</summary>
* http://alexb.ninja/wc
* https://github.com/fatiherikli/worldcup (displays World Cup results in the terminal)
* https://github.com/ColtCarder/XMPP-World-Cup-Bot (Ruby/Blather XMPP Bot to private message live World Cup events as well as overall results.)
* https://github.com/gberger/hubot-world-cup-live (Hubot plugin that pushes World Cup goals to a chat room)
* World Cup SMS updates at http://worldcupsms.herokuapp.com/ by @andyjiang
* https://github.com/brenopolanski/chrome-worldcup2014-extension (World Cup 2014 - Chrome Extension)
* http://worldcup2014.meteor.com/ - betting pool app for @q42 built by @primigenus using @meteor
* https://github.com/Friss/WorldCup - World Cup matches with the arena in the background
* https://github.com/sestaton/WorldCupStats - World Cup stats and match information at the command line
</details>
## BACKGROUND

You can read a blog post about building the API here:
http://softwareforgood.com/soccer-good/

## DONATIONS

Some people have asked if they can make donations. I'd love for you to donate some time writing code or docs or tests, but this is shared totally gratis. If you're interested in throwing some cash someone's way, why not help out organizations working wwith refugees or across borders. At this time of coming together as a human community, let's remember that arbitrary lines on a map still have the power to hurt people.
[Doctors Without Borders](https://donate.doctorswithoutborders.org/secure/onetime-donate)
[Aegean Boat Report](https://aegeanboatreport.com/donate/)


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
