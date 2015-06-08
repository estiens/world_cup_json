namespace :setup do
  desc "setup the teams"
  task generate_teams: :environment do
    Team.destroy_all

    path = Rails.root+"lib/assets/team.json"
    file = File.read(path)
    teams = JSON.parse(file)
    teams.each do |team|
      t = Team.new
      t.country = team["name"]
      t.alternate_name = team["alternate_name"]
      t.group_id = team["group_id"]
      t.fifa_code = team["code"]
      t.save
    end
  end
end
