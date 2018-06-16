# frozen_string_literal: true

class Team < ActiveRecord::Base
  has_many :events
  belongs_to :group

  before_save :write_iso_code
  before_save :write_stats

  has_many :home_matches, class_name: Match, foreign_key: 'home_team_id' do
    def completed
      where('status = ?', 'completed')
    end

    def wins
      where('status = ? AND home_team_score > away_team_score OR home_team_penalties > away_team_penalties', 'completed')
    end

    def losses
      where('status = ? AND home_team_score < away_team_score OR home_team_penalties < away_team_penalties', 'completed')
    end
  end

  has_many :away_matches, class_name: Match, foreign_key: 'away_team_id' do
    def completed
      where('status = ?', 'completed')
    end

    def wins
      where('status = ? AND home_team_score < away_team_score OR home_team_penalties < away_team_penalties', 'completed')
    end

    def losses
      where('status = ? AND home_team_score > away_team_score OR home_team_penalties > away_team_penalties', 'completed')
    end
  end
  def matches
    Match.where('home_team_id = ? OR away_team_id = ?', id, id)
  end

  def home_wins
    home_matches.wins.count
  end

  def home_goals_for
    home_matches.completed.sum(:home_team_score)
  end

  def away_goals_for
    away_matches.completed.sum(:away_team_score)
  end

  def home_goals_against
    home_matches.completed.sum(:away_team_score)
  end

  def away_goals_against
    away_matches.completed.sum(:home_team_score)
  end

  def away_wins
    away_matches.wins.count
  end

  def home_losses
    home_matches.losses.count
  end

  def away_losses
    away_matches.losses.count
  end

  def team_draws_count
    matches.where('status = ? AND home_team_score = away_team_score AND home_team_penalties IS NULL', 'completed').count
  end

  def team_wins_count
    home_wins + away_wins
  end

  def team_losses_count
    home_losses + away_losses
  end

  def team_goals_for_count
    home_goals_for + away_goals_for
  end

  def team_goals_against_count
    home_goals_against + away_goals_against
  end

  def goal_differential_count
    team_goals_for - team_goals_against
  end

  def team_points_count
    (team_wins_count * 3) + team_draws_count
  end

  def games_played_count
    team_wins_count + team_losses_count + team_draws_count
  end

  private

  def write_stats
    self.team_wins = team_wins_count
    self.team_losses = team_losses_count
    self.team_draws = team_draws_count
    self.games_played = games_played_count
    self.team_points = team_points_count
    self.team_goals_for = team_goals_for_count
    self.team_goals_against = team_goals_against_count
    self.team_goal_differential = goal_differential_count
  end

  def write_iso_code
    return if iso_code
    json = File.read(Rails.root.join('lib', 'assets', 'country_code.json'))
    json = JSON.parse(json)
    code = json.select { |_k, v| v.casecmp(country).zero? }
    self.iso_code = code.keys.first
  end
end
