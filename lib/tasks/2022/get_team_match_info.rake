require 'HTTParty'

BASE_URL = 'https://api.fifa.com/api/v3/calendar/matches'.freeze
BASE_PARAMS = '?from=2022-11-19T00%3A00%3A00Z&to=2022-12-31T23%3A59%3A59Z&language=en&count=500&idCompetition=17'.freeze

namespace :setup2022 do
  task seed_teams: :environment do
    team_json = File.read(Rails.root.join('lib/assets/wc2022/teams.json'))
    teams = JSON.parse(team_json)
    teams.each do |team|
      attrs = { fifa_code: team['fifa_code'], country: team['short_name'],
                flag_url: team['flag_url'], alternate_name: team['full_name'] }
      Team.find_or_create_by(attrs)
    end

    group_json = File.read(Rails.root.join('lib/assets/wc2022/groups.json'))
    groups = JSON.parse(group_json)
    groups.each do |g|
      group = Group.find_or_create_by(letter: g.first[0])
      next if group.teams.count == 4

      g.first[1].each do |name|
        team = Team.find_by(alternate_name: name)
        team ||= Team.find_by(country: name)
        raise "Could not find team for #{name}" unless team

        group.teams << team
      end
    end
  end

  # t.string 'location'
  # t.datetime 'datetime', precision: nil
  # t.string 'fifa_competition_id'
  # t.string 'fifa_season_id'
  # t.string 'fifa_group_id'
  # t.string 'fifa_stage_id'
  # t.string 'stage_name'
  task setup_matches: :environment do
    Match.destroy_all

    response = HTTParty.get(BASE_URL + BASE_PARAMS)
    json = JSON.parse(response.body)
    matches = json['Results']
    matches.each do |match_json|
      match_data = Scrapers::JsonMatch.new(match_json)
      attrs = {
        home_team_id: match_data.home_team&.id,
        away_team_id: match_data.away_team&.id,
        datetime: match_data.date,
        location: match_data.location,
        venue: match_data.venue,
        latest_json: match_json.to_json,
      }
      Match.find_or_create_by!(attrs)
    end
  end
end
