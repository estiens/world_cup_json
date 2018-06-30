class Match < ActiveRecord::Base
  validates_presence_of :location, :venue, :datetime, :status
  validate :has_teams

  belongs_to :home_team, class_name: Team, foreign_key: 'home_team_id'
  belongs_to :away_team, class_name: Team, foreign_key: 'away_team_id'
  belongs_to :winner, class_name: Team, foreign_key: 'winner_id'

  has_many :events
  has_many :match_statistics

  before_save :determine_winner
  before_save :set_default_status
  after_save :update_teams

  def self.for_date(start_time, end_time = nil)
    parse_times(start_time, end_time)
    return Match.none unless @start_time && @end_time
    where(datetime: @start_time..@end_time)
  end

  def self.parse_times(start_time, end_time)
    start_time = Chronic.parse(start_time.to_s)
    end_time = Chronic.parse(end_time.to_s)
    end_time ||= start_time
    return unless start_time && end_time
    @start_time = start_time.beginning_of_day
    @end_time = end_time.end_of_day
  end

  def self.next
    today.future.reorder(datetime: :asc).first
  end

  def self.recently_completed
    today.completed.reorder(datetime: :desc).first
  end

  def self.yesterday
    for_date(Time.now - 1.day)
  end

  def self.today
    for_date(Time.now)
  end

  def self.tomorrow
    for_date(Time.now.advance(days: 1))
  end

  def self.completed
    where(status: 'completed')
  end

  def self.not_completed
    where.not(status: 'completed')
  end

  def self.in_progress
    where(status: 'in progress')
  end

  def self.scheduled_now
    today.future.where('datetime < ?', Time.now)
  end

  def self.future
    where(status: 'future')
  end

  def self.not_future
    where.not(status: 'future')
  end

  def name
    home_team_desc = home_team&.country || home_team_tbd
    away_team_desc = away_team&.country || away_team_tbd
    "#{home_team_desc} vs #{away_team_desc}"
  end

  def completed?
    status == 'completed'
  end

  def home_team_events
    events.where(team: home_team)
  end

  def away_team_events
    events.where(team: away_team)
  end

  def home_stats
    match_statistics.where(team: home_team).first
  end

  def away_stats
    match_statistics.where(team: away_team).first
  end

  private

  def penalty_winner
    return nil if stage_name.downcase.include?('first stage')
    return nil unless json_home_team_penalties > 0 || json_away_team_penalties > 0
    return home_team if json_home_team_penalties > json_away_team_penalties
    return away_team if json_away_team_penalties > json_home_team_penalties
    nil
  end

  def regulation_winner
    return nil unless home_team_score && away_team_score
    return home_team if home_team_score > away_team_score
    return away_team if away_team_score > home_team_score
    nil
  end

  def draw?
    return nil unless stage_name.downcase.include?('first stage')
    home_team_score == away_team_score
  end

  private

  def set_default_status
    self.status ||= 'undetermined'
  end

  def has_teams
    home = (home_team.present? || home_team_tbd.present?)
    away = (away_team.present? || away_team_tbd.present?)
    return if home && away
    errors.add(:base, 'Missing home team') unless home
    errors.add(:base, 'Missing away team') unless away
  end

  def determine_winner
    return unless status == 'completed'
    self.winner = penalty_winner
    self.winner ||= regulation_winner
    self.draw = draw?
    true
  end

  def update_teams
    home_team&.save && away_team&.save
  end
end
