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

    Team.all.each do |t|
      t.wins = t.wins.to_i
      t.losses = t.losses.to_i
      t.draws = t.draws.to_i
      t.goals_for = t.goals_for.to_i
      t.goals_against = t.goals_against.to_i
      t.knocked_out = false
      t.save
    end

  end

end
