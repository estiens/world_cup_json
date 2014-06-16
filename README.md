== ABOUT

This is a simple backend for a scraper that grabs current world cup results and outputs them as JSON.

== SETUP

Clone the repo

run rake setup:generate_teams to generate the teams

run rake fifa:get_group_results as a cron job, with whatever time frame you want - This pulls in the standings of the group stages

run rake fifa:get_all_matches as a cron job, with whatever time frame you want - This pulls in all matches and updates any that need updating

==TODO

* Static landing page
* Add CSS class to determine knocked out teams

==ENDPOINTS

[url]/teams.json for a list of teams with group ID and FIFA code

[url]/group_results.json for current results (wins, losses, draws, goals for, goals against, knock out status)

[url]/matches.json for all matches (Example JSON object at the bottom of this README)

==OTHER ENDPOINTS

[url]/matches/today.json
[url]/matches/tomorrow.json

(what it says on the tine)

You can also retrieve the matches for any team if you know their FIFA code by passing it in as a param.

Example: [url]/matches/country?fifa_code=USA

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
