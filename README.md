== ABOUT

This is a simple backend for a scraper that grabs current world cup results and outputs them as JSON.

== SETUP

* Clone the repo

* ```rake setup:generate_teams``` to generate the teams

* Run the following two tasks as cron jobs, to pull in data with whatever time frame you want (every 5 minutes for example):
```rake fifa:get_group_results``` (This pulls in the standings of the group stages)
```rake fifa:get_all_matches``` (This pulls in all matches and updates any that need updating)

==TODO

* Static landing page
* Add CSS class to determine knocked out teams

==ENDPOINTS

    [url]/teams/
for a list of teams with group ID and FIFA code

    [url]/group_results/
for current results (wins, losses, draws, goals for, goals against, knock out status)

    [url]/matches/
for all matches (Example JSON object at the bottom of this README)

==OTHER ENDPOINTS

    [url]/matches/today/
    [url]/matches/tomorrow/

(what it says on the tin)

You can also retrieve the matches for any team if you know their FIFA code by passing it in as a param.

    Example: [url]/matches/country?fifa_code=USA

==Optional Parameters

You can append `?by_date=desc` to any query tosort the matches by furthest in the future to furthest in the past. `?by_date=asc` does past to future.

    Example:[url]/matches/today/?by_date=DESC

Gives you today's matches in reverse order from latest to earliest.

== EXAMPLE RESPONSES

MATCH API

```json
{
match_number: 1,
location: "Arena Corinthians",
datetime: "2014-06-12T17:00:00.000-05:00",
status: "completed",
home_team: {
country: "Brazil",
code: "BRA",
goals: 3
},
away_team: {
country: "Croatia",
code: "CRO",
goals: 1
},
winner: "Brazil"
},
```
GROUP RESULTS API

```json
{
country: "Brazil",
alternate_name: null,
fifa_code: "BRA",
group_id: 1,
wins: 1,
draws: 0,
losses: 0,
goals_for: 3,
goals_against: 0,
knocked_out: false,
updated_at: "2014-06-14T01:06:52.484-05:00"
},
```

== TRY IT OUT

http://world-cup-json.herokuapp.com/matches

http://world-cup-json.herokuapp.com/matches/today

http://world-cup-json.herokuapp.com/group_results

http://world-cup-json.herokuapp.com/teams
