# frozen_string_literal: true

class Event < ActiveRecord::Base
  belongs_to :match
  belongs_to :team

  def data_hash
    return @data_hash if @data_hash
    return {} unless event_json && JSON.parse(event_json).is_a?(Hash)

    @data_hash ||= JSON.parse(event_json)
  end

  def event_team_id
    @team&.id || data_hash['IdTeam']
  end

  def event_player_id
    data_hash['IdPlayer']
  end

  def event_time
    data_hash['Minute']
  end

  def event_id
    return data_hash['IdEvent'] if data_hash['IdEvent'].present?

    "#{event_team_id}_#{event_match_id}_#{event_time}"
  end
end
