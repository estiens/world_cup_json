BASE_URL = 'https://api.fifa.com/api/v3/calendar/matches'.freeze
BASE_PARAMS = '?from=2022-11-19T00%3A00%3A00Z&to=2022-12-31T23%3A59%3A59Z&language=en&count=500&idCompetition=17'.freeze

class Setup2022
  def self.setup_teams
    team_json = File.read(Rails.root.join('lib/assets/wc2022/teams.json'))
    teams = JSON.parse(team_json)
    teams.each do |team|
      attrs = { fifa_code: team['fifa_code'], country: team['short_name'],
                flag_url: team['flag_url'], alternate_name: team['full_name'] }
      new_team = Team.new(attrs)
      new_team.save(validate: false)
    end
  end

  def self.parse_groups
    group_json = File.read(Rails.root.join('lib/assets/wc2022/groups.json'))
    JSON.parse(group_json)
  end

  def self.setup_groups
    parse_groups.each do |g|
      group = Group.find_or_create_by(letter: g.first[0])
      group.teams = []
      g.first[1].each do |name|
        team = Team.find_by(alternate_name: name) || Team.find_by(country: name)
        raise "Could not find team for #{name}" unless team

        group.teams << team
      end
      group.save
    end
  end
end
