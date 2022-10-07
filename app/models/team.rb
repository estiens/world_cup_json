# frozen_string_literal: true

class Team < ActiveRecord::Base
  has_many :events
  has_many :home_matches, class_name: 'Match', foreign_key: 'home_team_id'
  has_many :away_matches, class_name: 'Match', foreign_key: 'away_team_id'
  belongs_to :group

  # before_save :write_stats

  def home_completed
    home_matches.where('status = ?', 'completed')
  end

  def home_wins
    home_matches_completed.where(winner: self)
  end

  def home_losses
    home_matches_completed.where(winner: away_team)
  end

  def away_completed
    away_matches.where('status = ?', 'completed')
  end

  def away_wins
    away_matches_completed.where(winner: self)
  end

  def away_losses
    away_matches_completed.where(winner: home_team)
  end

  def matches
    Match.where('home_team_id = ? OR away_team_id = ?', id, id)
  end

  def home_win_count
    home_wins.count
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

  def away_wins_count
    away_wins.count
  end

  def home_losses_count
    home_losses.count
  end

  def away_losses_count
    away_losses.count
  end

  def team_draws_count
    matches.where('status = ? AND home_team_score = away_team_score AND home_team_penalties IS NULL', 'completed').count
  end

  def team_wins_count
    home_wins_count + away_wins_count
  end

  def team_losses_count
    home_losses_count + away_losses_count
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
    attrs = { team_wins: team_wins_count, team_losses: team_losses_count,
              team_draws: team_draws_count, team_goals_for: team_goals_for_count,
              games_played: games_played_count, team_points: team_points_count,
              team_golas_for: team_goals_for_count, team_goals_against: team_goals_against_count,
              team_goal_differential: goal_differential_count }
    update(attrs)
  end
end
