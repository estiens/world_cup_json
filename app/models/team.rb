class Team < ActiveRecord::Base
  has_many :events
  has_many :home_matches, class_name: 'Match', foreign_key: 'home_team_id'
  has_many :away_matches, class_name: 'Match', foreign_key: 'away_team_id'
  belongs_to :group

  before_validation :write_stats

  def to_s
    alternate_name
  end
  alias name to_s

  def home_completed
    home_matches.where('status = ?', 'completed')
  end

  def last_match
    matches.where(status: 'completed').max_by(&:datetime)
  end

  def next_match
    matches.where(status: 'future_scheduled').min_by(&:datetime)
  end

  def home_wins
    home_completed.where(winner: self)
  end

  def home_losses
    home_completed.where.not(winner: self)
  end

  def away_completed
    away_matches.where('status = ?', 'completed')
  end

  def away_wins
    away_completed.where(winner: self)
  end

  def away_losses
    away_completed.where.not(winner: self)
  end

  def matches
    Match.where('home_team_id = ? OR away_team_id = ?', id, id)
  end

  def home_wins_count
    home_wins.count
  end

  def home_goals_for
    home_completed.sum(:home_team_score)
  end

  def away_goals_for
    away_completed.sum(:away_team_score)
  end

  def home_goals_against
    home_completed.sum(:away_team_score)
  end

  def away_goals_against
    away_completed.sum(:home_team_score)
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
    matches.where('status = ? AND home_team_score = away_team_score AND home_team_penalties < 1', 'completed').count
  end

  def team_wins_count
    home_wins_count + away_wins_count
  end

  def team_losses_count
    home_losses_count + away_losses_count
  end

  def team_goals_for_count
    home_goals_for.to_i + away_goals_for.to_i
  end

  def team_goals_against_count
    home_goals_against.to_i + away_goals_against.to_i
  end

  def goal_differential_count
    team_goals_for.to_i - team_goals_against.to_i
  end

  def team_points_count
    (team_wins_count * 3) + team_draws_count
  end

  def games_played_count
    team_wins_count + team_losses_count + team_draws_count
  end

  private

  def write_stats
    assign_attributes(team_wins: team_wins_count, team_losses: team_losses_count, team_draws: team_draws_count)
    assign_attributes(team_goals_for: team_goals_for_count, team_goals_against: team_goals_against_count)
    assign_attributes(team_goal_differential: goal_differential_count, games_played: games_played_count,
                      team_points: team_points_count)
  end
end
