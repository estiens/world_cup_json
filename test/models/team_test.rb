require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  test "derived wins equal scraped wins" do
    Team.all.each do |team|
      assert_equal(team.wins, team.team_wins)
    end
  end

  test "derived losses equal scraped losses" do
    Team.all.each do |team|
      assert_equal(team.losses, team.team_losses)
    end
  end

  test "derived draws equal scraped draws" do
    Team.all.each do |team|
      assert_equal(team.draws, team.team_draws)
    end
  end

  test "derived goals_for equal scraped goals_for" do
    Team.all.each do |team|
      assert_equal(team.goals_for, team.team_goals_for)
    end
  end

  test "derived goals_against equal scraped against" do
    Team.all.each do |team|
      assert_equal(team.goals_against, team.team_goals_against)
    end
  end

end
