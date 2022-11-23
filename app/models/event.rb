# frozen_string_literal: true

class Event < ActiveRecord::Base
  belongs_to :match
  belongs_to :team
  validates :event_json, presence: true
  validates :fifa_id, presence: true

  before_validation :create_from_json
  after_save :notify_slack

  def data_hash
    return @data_hash if @data_hash
    return {} unless event_json && JSON.parse(event_json).is_a?(Hash)

    @data_hash ||= JSON.parse(event_json).with_indifferent_access
  end

  def type_of_event
    read_attribute(:type_of_event)&.to_sym
  end

  private

  def event_id
    return data_hash[:event_id] if data_hash[:event_id].present?

    "#{event_team_id}_#{match&.id}_#{event_time}_#{type_of_event}"
  end

  def event_team_id
    event_team = team || Team.find(data_hash[:team_id]) || Team.find_by(fifa_code: data_hash[:id_team])
    event_team&.id
  end

  def event_player_name
    data_hash[:player_name]
  end

  def event_time
    data_hash[:minute]
  end

  def write_identifiers
    self.fifa_id ||= event_id
    self.type_of_event = type_of_event
  end

  def home_team_event
    return false unless match && team

    team == match.home_team
  end

  def event_player
    data_hash[:player_name] || data_hash[:player_on]
  end

  def extra_info_text
    return nil unless type_of_event == :substitution

    { player_off: data_hash[:player_off], player_on: data_hash[:player_on] }.to_json
  end

  def write_details
    self.player ||= event_player&.titlecase
    self.time ||= event_time
    self.home_team = home_team_event
    self.extra_info = extra_info_text
  end

  def create_from_json
    return if Event.find_by(fifa_id: event_id, match: match, team: team)

    write_identifiers
    write_details
  end

  def goal_text
    ['GOAL!', 'Goooooooollllllll!', 'Goooooooooooooooooooooal!'].sample
  end

  def booking_text
    ['Yellow card!', "That's a card for you, sir!", "The ref's into his pocket", '*whistle* Booked!'].sample
  end

  def substitution_text
    "Substitution #{team.country} #{player} on for #{extra_info[:player_off]} at #{time}"
  end

  def slack_message_text
    case type_of_event.to_sym
    when :goal
      "#{goal_text} -- #{player} #{team.country} #{time}"
    when :booking
      "#{booking_text} -- #{player} #{team.country} at #{time}'"
    when :substitution
      substitution_text
    end
  end

  def slack_emoji_hash
    { goal: ':soccer:', booking: ':large_yellow_square:', substitution: ':arrow_up_down:' }
  end

  def slack_message_params
    emoji = slack_emoji_hash[type_of_event.to_sym]
    emoji || ':soccer:'
    { message: slack_message_text, emoji: emoji }
  end

  def notify_slack
    return unless slack_message_params[:message].present?

    SlackMessageService.new(message: slack_message_params[:message], emoji: slack_message_params[:emoji]).notify
  rescue StandardError => e
    Rails.logger.warn "Error notifying slack: #{e.message}"
  end
end
