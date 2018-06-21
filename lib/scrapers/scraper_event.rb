# frozen_string_literal: true

module Scrapers
  class ScraperEvent
    def initialize(event)
      @event = event
    end

    def event_detail
      @event_detail ||= @event.children.css('.fi-p__event')&.first
    end

    def type
      return nil unless event_detail
      type = event_detail.attributes['class']&.value
      return nil unless type
      type.gsub('fi-p__event', '').gsub('--', '')&.strip
    end

    def minute
      return nil unless event_detail
      minute = event_detail.attributes['title']&.value
      return nil unless minute
      minute.to_s.downcase
    end

    def player
      attrs = @event.parent&.parent&.attributes
      return nil unless attrs
      attrs['data-player-name']&.value&.strip
    end

    def home?
      parent = @event.parent&.parent&.parent
      return nil unless parent
      value = parent.attributes['class']&.value
      return nil unless value
      value.include?('home')
    end
  end
end
