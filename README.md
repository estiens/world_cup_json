# FIFA WORLD CUP 2022

## and we made it! 2024 WWC or 2026 MWC in US/Canada/Mexico is anyone's game :D Congrats to Argentina!

--

We are super up and running for 2022. Note URL change! Please remember to make a PR with your nice apps, raspberry pi projects, etc. And my favorite part of this whole thing, the students who get super excited about coding something.

Update: Have finally hit 10k RPM for 2022 as well!

## PROJECTS USING THIS API IN 2022

(Feel free to submit a PR with your project!)

- https://github.com/cyrusDev1/qatar-worldcup
  (Vue Js Web App to find the matches, scores and rankings of the Qatar 2022 world cup in real time.)
- [2022 Interactive Bracket](https://worldcup.cole.ws/)
  (2022 FIFA World Cup Bracket: A simple website designed to help you track 2022's FIFA World Cup bracket.)

- https://github.com/charles-wangkai/betbot_worldcup (Slack App for FIFA World Cup Bets)

- https://github.com/cedricblondeau/world-cup-2022-cli-dashboard
  (Watch live matches in your terminal)

- [Live-Cup](https://live-cup.pedsm.dev) [repo](https://github.com/pedsm/liveCup)
  (React.js based dashboard with live updates designed for TVs and Computers)

- https://github.com/dg01d/bitbar-worldcup
  (Plugin for xbarapp, displays scores in macos menubar.)
- [CopaInfo](https://github.com/Eslley/copainfo) React.js web app to follow matches, scores, standings and favorite team

- [Zero-goal Match Checker](https://matthewmcvickar.com/zero-goal-checker/) ([GitHub repo](https://github.com/matthewmcvickar/world-cup-zero-goal-match-checker)) &mdash; checks if completed matches ended in a 0&ndash;0 score

- [worldcup.js](https://www.npmjs.com/package/worldcup.js?a#matchweather) ([GitHub repo](https://github.com/yodalightsabr/worldcup.js)) A client for this API in JavaScript

- [World Cup Scores](https://world-cup-score-app.vercel.app/) ([GitHub repo](https://github.com/jgeorge97/world-cup-score-app)) A simple Vue Typescript Web app to show the scores & timings of the current & upcoming matches

- [CopaQatar](https://copaqatar-vitor.netlify.app/) [repo](https://github.com/vitorFRE/CopaQatar)
  (A simple world cup website to see groups, matches, current match.)


- [WorldCupResults](https://world-cup-results-2022.vercel.app/) [repo](https://github.com/yasincandev/fifa-world-cup-2022)
  (NextJs, Chackra, React Query based web app to see live results of the matches and details)

  
- [World Cup Bar](https://cyrilniobe.gumroad.com/l/world-cup-mac-bar) A Mac menu bar app to watch today's live score and results while working.

- [FIFA World Cup 2022 Encyclopedia](https://github.com/mufratkarim/FIFA-World-Cup-2022-Encyclopedia) (A simple android app that displays complete complete stats of the world cup)


todo:

- scrape match statistics

fixed:

- issue with hanging/overloaded workers for scraping
- match start detection

Setup: usual rails setup then
`Setup2022.setup_teams`
`Setup2022.setup_groups`
`AllMatchesService.setup`

And if you have 64 matches you are good to go! From there on out you can call jobs directly or use the
`app/jobs/scheduler.rb` to update them. If you want to run the scraping tasks automatically, you'll need another tab open and run `ENABLE_CRON=true bundle exec good_jobs start`

https://worldcupjson.net

Main response endpoint:
https://worldcupjson.net/matches/today

## DETAILED EXAMPLE RESPONSE

[detailed_response](https://gist.github.com/estiens/8c8de685fd74821c273cc9160ad9d765)

\*\* note if match statistics make it in, they are all ints - but I have to find them!

(note, the full matches endpoint has up to a 5 minutes cache on it and does not return all events - if you want real time updates please use `/matches/today`, `/matches/id`, or `/matches/current`)

## ABOUT

This is a simple backend for a scraper that grabs current world cup results and outputs them as JSON. UPDATE 8 Jun 2015 - This is now working for the Women's World Cup. UPDATE 14 June 2018 - Updated for the World Cup in 2018 with 7 hours to spare! Update 13 Oct 2022- Guess we'll do this again!

Special thanks to my former employer [Software For Good](https://softwareforgood.com/) for encouraging me to make this many years ago...

## RATE LIMITING

The current rate limit is 10 requests every 60 seconds. This is open to change at anytime depending on load, but I'll always keep it so a few requests can fire off in parallel. Please keep your polling down to once a minute or so, 30 seconds if you are feeling greedy, you're not going to get updated information any quicker than that.

## ENDPOINTS

(some of the teams endpoints were never used may be deprecated for 2022)

`[url]/teams/` for a list of teams with group ID and FIFA code

`[url]/matches/`
for all matches (Example JSON object at the bottom of this README)

Note - if you want all matches with all details,you must now pass `?details=true` to this endpoint.
All details will be present by default for endpoints like `matches/today` that return less matches...

`[url]/teams/` results for each team (wins, losses, points, goals_for, goals_away, games_played)

`[url]/teams/USA` see next match info, last match info, current standings, etc

## OTHER ENDPOINTS

```
[url]/matches/today/
[url]/matches/tomorrow/
[url]/matches/current/
```

You can also retrieve the matches for any team if you know their FIFA code (get fifa code from teams endpoint) by passing it in as a param.

    Example: [url]/matches/country?fifa_code=ISL

## Other Params

- You can append a start date or a start date and and end date to get the matches for those dates. Example `/matches?start_date=2018-06-19&end_date=2018-06-21` Please use YYYY-MM-DD as your param. `end_date` is optional.

- You can append `?callback=foo` to get a JSONP response

  Example: `https://worldcupjson.net/matches/today?callback=bar`

- You can append `?by_date=desc` to any query to sort the matches by furthest in the future to furthest in the past. `?by_date=asc` does past to future. (ASC is default sort with no params)

  Example:`[url]/matches/today/?by_date=DESC`

You can also use the by param to get some other sortings of the match list.

- `total_goals` will sort matches with the largest number of total goals to the least
- `home_team_goals` will sort matches with the largest number of home team goals to the least
- `away_team_goals` will sort matches with the largest number of away team goals to the least
- `closest_scores` will sort matches with draws first to largest winning margin

  Example:`[url]/matches/current/?by=closest_scores`

#### JSONP

JSONP old school
The API also supports [JSONP](http://en.wikipedia.org/wiki/JSONP) style output via the `callback` parameter, e.g. `[url]/teams/results?callback=processData`

The response includes the same data output as the regular GET call without parameters, but wrapped inside a function. This can be used to get around cross origin issues.

## EXAMPLE RESPONSES

[Detailed Match View](https://gist.github.com/estiens/8c8de685fd74821c273cc9160ad9d765)

## PROJECTS USING THIS API IN 2018

<details><summary>2018 projects submitted</summary>

- http://fifa-worldcup.herokuapp.com
  (NodeJS and Express Web App to keep you updated with the FIFA World Cup 2018)

- http://meisam-dodangeh.ir/worldcup (A simple web Page to show today games and games events)
- https://m.me/244560172984721 (Facebook Messenger bot that shows games for today and tomorrow as well as allowing you to follow along with live matches)

- https://github.com/jthomas/goalbot
  (Twitter bot ([@WC2018_Goals](https://twitter.com/WC2018_Goals)) which tweets out every goal from the 2018 FIFA World Cup.)
- https://github.com/riceluxs1t/EloSoccerPrediction
  (React.js + Django app that shows (live) game data and match outcome predictions using an ELO based Poisson model.)

- https://github.com/justcallmelarry/sportsball
  (slack integration for updates of goals, cards and results)

- https://github.com/selfish/worldcup-slack
  (Node.js Slack game status announcer, updated for 2018 games)

- https://github.com/dg01d/bitbar-worldcup
  (BitBar plugin to show current/daily scores and results)

- https://github.com/nicolopignatelli/wc2018-slack-bot
  (Slack bot for updates about the current match)

- https://github.com/wildlifehexagon/node-world-cup
  (Node.js command line app to display results and standings)

- https://github.com/iricigor/FIFA2018
  (PowerShell wrapper, compatible with both Linux and Windows versions)

- https://github.com/pedsm/liveCup
  (React.js based dashboard with live updates designed for TVs and Computers)

- https://github.com/johnbfox/world-cup-scores-cli
  (Command line tool for getting the day's scores and goals)

- https://github.com/cedricblondeau/world-cup-2018-cli-dashboard
  (CLI Dashboard that displays live updates of the current game, today's schedule and groups, built with react-blessed)

- https://github.com/sazap10/world-cup-discord-bot
  (Discord bot to display schedule, match information and standings)

- https://github.com/luridarmawan/Carik/
  ([Carik](https://github.com/luridarmawan/Carik/) ChatBot for Facebook Messenger, Telegram, Line, Slack. just type "info world cup".) See screenshots [1](https://cl.ly/102h2A1a3S46) [2](https://cl.ly/1p123j342A3v) [3](https://cl.ly/1T0i1E1P410B)

- https://github.com/arghgr/golbot
  (Twitter bot that tweets the word GOL, with varying numbers of Os, whenever a goal is scored - [@worldcupgolbot](https://twitter.com/worldcupgolbot))

- https://github.com/kadinho/worldcup-notifications
  (A project to fetch FIFA World Cup matches and send Slack event notifications)

- https://github.com/gk4m/world-cup-scores
  (Simple vue.js based app for displaying results from World Cup 2018.)

- https://apps.lametric.com/apps/fifa_world_cup_2018/6624
  (Display the latest score of the current match(es), or the recent and next matches on a [LaMetric Time](https://lametric.com) device)

- https://world-cup-basecamp.herokuapp.com/
  [Github Link](https://github.com/dskoda1/world-cup-basecamp) - SPA using React/Redux/Material for displaying data from this API

- https://spapas.github.io/wc2018/
  (A WC2018 dashboard using vue.js. Source @ https://github.com/spapas/vue-wc2018)

- https://github.com/eeddaann/ElastiCup
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

## TRY IT OUT

[https://worldcupjson.net/matches](https://worldcupjson.net/matches)

[https://worldcupjson.net/matches/today](https://worldcupjson.net/matches/today)

[https://worldcupjson.net/matches/current](https://worldcupjson.net/matches/current)

[https://worldcupjson.net/teams](https://worldcupjson.net/teams)

[https://worldcupjson.net/teams/USA](https://worldcupjson.net/teams/USA)

## UPDATES

### Updates June 19, 2018

- New rate limit -- some of you are really hammering the server. You can now make 10 requests
  every 60 seconds, requests after that will return 429
  with your reset time. Please try to limit polling to once every minute or so and if you are building a SPA please do some cacheing/storing on your side and don't send a request with every user interaction. If you need a whitelist for more requests, please let me know and we can do it, but right now fully half of the requests get throttled and it's a fair amount of load to deal with that many requests coming in more often than 10s apart.

- Better cacheing/fixed broken JSONP cacheing

- Scrapers almost finished being reworked

- New param added to the matches endpoint. You can pass `?start_date=2018-06-21` or `?start_date=2018-06-19&end_date=2018-06-24`

  (If you pass one date, you'll get matches for that day, otherwise for the range of days specified. Please use YYYY-MM-DD format even though it is weird for the rest of the world not to use YYYY-DD-MM)

### Updates June 18, 2018

- We now retrieve match statistics as well (attempts on goal, saves, etc). This will show up at all the matches endpoints. If you want a more truncated view of a match (no events or stats) please pass `?details=false` to any match endpoint

- You can now retrieve a match by fifa_id if you only want one specific match, just use `/matches/fifa_id/300331499` or as a shortcut just `/matches/300331499`. You'll get a 404 error back if no match has that id.

- Scrapers are being refactored to actually have readable methods, memoize parsed information, etc. Views not calculating anything should increase response time considerably, which is good as we are now at about 30-40 rps.

## WARNING

Removing self deprecating warning. I wrote the best code I could 4 years ago and got it working for the whole Cup, and I'm making it better now. Don't apologize for code you write in a rush to build a cool thing! A bad habit! Just make it better if/when you can.

https://www.linkedin.com/pulse/world-cup-api-take-2-eric-stiens/
