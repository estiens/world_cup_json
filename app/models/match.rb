class Match < ActiveRecord::Base
  belongs_to :home_team, class_name: 'Team', foreign_key: 'home_team_id', optional: true
  belongs_to :away_team, class_name: 'Team', foreign_key: 'away_team_id', optional: true
  belongs_to :winner, class_name: 'Team', foreign_key: 'winner_id', optional: true

  has_many :events
  has_many :match_statistics

  before_validation :set_default_status
  before_save :update_status

  after_save :update_teams

  STATUSES = %i[incomplete future_unscheduled future_scheduled in_progress completed].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :fifa_competition_id, presence: true

  validate :validate_basic_info, unless: proc { |m| m.status == :incomplete }

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
    where(status: :completed)
  end

  def self.not_completed
    where.not(status: :completed)
  end

  def self.in_progress
    where(status: :in_progress)
  end

  def self.scheduled_now
    today.future.where('datetime < ?', Time.now)
  end

  def self.future
    where(status: :future_scheduled).or(where(status: :future_unscheduled))
  end

  # check if we even call this
  def self.not_future
    where.not(status: 'future')
  end

  def status
    read_attribute(:status)&.to_sym || :incomplete
  end

  def incomplete?
    return true if status.nil?
    return true if status == :incomplete

    false
  end

  def teams_assigned?
    home_team && away_team
  end

  def name
    home_team_desc = home_team&.country || home_team_tbd
    away_team_desc = away_team&.country || away_team_tbd
    "#{home_team_desc} vs #{away_team_desc}"
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

  # def update_self_from_latest_data
  #   Services::MatchUpdater.new(self).update
  # end

  private

  def validate_basic_info
    return if fifa_competition_id && fifa_season_id && fifa_stage_id && fifa_group_id

    errors.add(:base, 'Match is missing basic information')
  end

  def validate_teams_exist
    return if %i[incomplete future_unscheduled].include? status
    return if home_team_id && away_team_id

    errors.add(:base, 'Cannot schedule game without teams')
  end

  def penalty_winner
    return nil unless status == :completed
    return nil unless away_team_penalties.to_i.positive? && home_team_penalties.positive?
    return home_team if home_team_penalties > away_team_penalties
    return away_team if away_team_penalties > home_team_penalties

    nil
  end

  def regulation_winner
    return nil unless status == :completed
    return home_team if home_team_score > away_team_score
    return away_team if away_team_score > home_team_score

    nil
  end

  def draw?
    return nil unless status == :completed
    return false unless stage_name.downcase.include?('first stage')

    home_team_score == away_team_score
  end

  def set_default_status
    self.status ||= :incomplete
  end

  def update_status
    identify! if status == :incomplete
    schedule! if status == :future_unscheduled
    # determine match is live! if future_scheduled
    # determine completed if in_progress
    determine_winner! if status == :completed
  end

  def schedule!
    return nil unless status == :future_unscheduled

    schedule_info = home_team_id && away_team_id && datetime
    return nil unless schedule_info

    self.status = :future_scheduled
  end

  def identify!
    return nil unless status == :incomplete

    # need these for URL and all matches should have
    complete_info = (fifa_id && fifa_stage_id)
    return nil unless complete_info

    self.status = :future_unscheduled
  end

  def determine_winner!
    # check winner against json?
    return unless status == :completed

    self.winner = penalty_winner
    self.winner ||= regulation_winner
    self.draw = draw?
  end

  def update_teams
    return unless status == :completed
    return if winner_id.present? || draw

    determine_winner!
    save && home_team.save && away_team.save
  end
end
