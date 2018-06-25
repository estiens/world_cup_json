# frozen_string_literal: true

module Scrapers
  # scrapes match statistics
  class EventScraper < BaseScraper
    def initialize(match:, force: false)
      super()
      @match = match
      @url = scraper_url
      @force = force
      @counter = 0
      @found = 0
    end

    def scrape
      @page = scrape_page_from_url
      try_match_facts
      try_match_events
      @match.save
    end

    private

    def scraper_url
      base_url = 'https://www.fifa.com/worldcup/matches/match/'
      "#{base_url}#{@match.fifa_id}/#match-lineups"
    end

    def try_match_events
      if write_match_events
        puts "Events saved for #{@match.name}"
      else
        puts "Skipped Match: #{@match.name}"
      end
    end

    def try_match_facts
      if write_match_facts
        puts "Goals updated for #{@match.name}"
      else
        puts "No goals updated for #{@match.name}"
      end
    end

    def write_match_facts
      if @match.completed? && !@force
        puts "#{@match.name} already completed"
        return
      end
      check_for_goals
      @match.time = match_time if match_time
      @match.last_score_update_at = Time.now
      @match.status = 'completed' if match_completed?
    end

    def write_match_events
      if @match.events_complete? && !@force
        puts "#{@match.name} already completed"
        return
      end
      puts "Grabbing events for #{@match.name}"
      puts "Couldn't find events for #{@match.name}" && return if events.empty?
      return unless write_events
      @match.last_event_update_at = Time.now
      @match.events_complete = true if @match.status == 'completed'
    end

    def check_for_goals
      goal_text = @page.search('.fi-s__scoreText')
      return nil unless goal_text
      goals = goal_text.children&.last&.text&.split('-')
      if goals.nil? || goals.length != 2
        goals = goal_text.children&.first&.text&.split('-')
      end
      return unless goals.length == 2
      update_team_score(goals)
    end

    def update_team_score(goals)
      home_team_score = goals.first.to_i
      away_team_score = goals.last.to_i
      if home_team_score > @match.home_team_score.to_i
        puts "GOOOOOOOL #{@match.home_team.country}"
        @match.home_team_score = home_team_score
      end
      return unless away_team_score > @match.away_team_score.to_i
      puts "GOOOOOOOOL #{@match.away_team.country}"
      @match.away_team_score = away_team_score
    end

    def write_events
      unless events.length.positive?
        puts "Couldn't find events for match"
        return false
      end
      events.each do |event|
        team_id = event[:home] ? @match.home_team_id : @match.away_team_id
        attrs = { player: event[:player], team_id: team_id,
                  type_of_event: event[:type], time: event[:time],
                  match_id: @match.id }
        find_or_create_event(attrs)
      end
      puts "scraped #{events.length} events
           | #{@counter} events created
           | #{@found} existed"
      true
    end

    def find_or_create_event(attrs)
      if Event.find_by(attrs)
        @found += 1
      else
        return unless Event.create(attrs)
        puts "#{attrs} event created"
        @counter += 1
      end
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
      match_time&.include? 'full-time'
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
