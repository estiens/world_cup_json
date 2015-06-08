namespace :setup do
  desc "setup the teams"
  task generate_teams: :environment do
    Team.destroy_all

    path = Rails.root+"lib/assets/team.json"
    file = File.read(path)
    teams = JSON.parse(file)
    groups = ('A'..'F').to_a
    groups.each do |group|
      new_group = Group.find_or_create_by_letter(group)
      new_group.letter = group
      new_group.save
    end
    teams.each do |team|
      t = Team.new
      t.country = team["name"]
      t.alternate_name = team["alternate_name"]
      t.group_id = team["group_id"]
      t.fifa_code = team["code"]
      t.save
    end
    Group.all.each do |group|
      raise "Something went wrong" if group.teams.count != 4
    end
    puts "#{Team.count} teams created successfully"
  end
end
