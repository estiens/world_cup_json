# frozen_string_literal: true

module Scrapers
  # scrapes match statistics
  class EventScraper < BaseScraper
    def initialize(match:)
      @match = match
      @url = scraper_url
      @page = scrape_page_from_url
    end

    def scrape
      if write_events
        puts "Stats saved for #{@match.name}"
      else
        puts "Skipped Match: #{@match.name}"
      end
    end

    private

    def scraper_url
      base_url = 'https://www.fifa.com/worldcup/matches/match'
      "#{base_url}/#{@match.fifa_id}/#match-lineups"
    end

    def write_match_events
      puts "Grabbing events for #{@match.name}"
      return nil if events.empty? || @match.status == 'completed'
      return nil unless write_events
      @match.time = match_time
      @match.last_event_update_at = Time.now
      @match.status == 'completed' if match_completed
      @match.save
    end

    def write_events
      events.each do |event|
        team_id = event[:home] ? @match.home_team_id : @match.away_team_id
        attrs = { player: event[:player], team_id: team_id,
                  type_of_event: event[:type], time: event[:time],
                  match_id: @match.id }
        next if Event.find_by(attrs)
        puts "#{attrs} event created" if Event.create(attrs)
      end
      true
    end

    def events
      events = []
      event_list.each do |event|
        event = Scrapers::ScraperEvent.new(event)
        event_hash = {
          type: event.type, player: event.player,
          time: event.minute, home: event.home?
        }
        events << event_hash
      end
      @events ||= events
    end

    def match_completed?
      match_time.include? 'full-time'
    end

    def match_time
      time = @page.css('.period').css(':not(.hidden)')
      @match_time ||= time&.children&.first&.text&.strip&.downcase
    end

    def event_list
      @event_list ||= @page.search('.fi-p__events .fi-p__events-wrap')
    end
  end
end
