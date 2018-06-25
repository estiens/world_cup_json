# frozen_string_literal: true

module Scrapers
  # scrapes match statistics
  class FactScraper < BaseScraper
    def initialize(match:, force: false)
      super()
      @match = match
      @url = scraper_url
      @force = force
      @try_counter = 0
    end

    def scrape
      if @match.stats_complete && !@force
        puts "Dont need stats for #{@match.name}"
        return
      end
      @page = scrape_page_from_url
      if write_match_stats
        puts "Stats saved for #{@match.name}"
      elsif @try_counter < 5
        @try_counter += 1
        puts "Trying again in 5 seconds..."
        sleep(5)
        self.scrape
      else
        puts "Skipped Match: #{@match.name}"
      end
    end

    private

    def scraper_url
      base_url = 'https://www.fifa.com/worldcup/matches/match'
      "#{base_url}/#{@match.fifa_id}/#match-statistics"
    end

    def all_stats
      %i[attempts_on_goal on_target off_target blocked woodwork
         corners offsides ball_possession pass_accuracy num_passes
         passes_completed distance_covered balls_recovered tackles
         clearances yellow_cards red_cards fouls_committed]
    end

    def write_match_stats
      return nil if @try_counter >=5
      return nil if stats.empty?
      return nil unless write_stats
      @match.stats_complete = true if @match.status == 'completed'
      @match.save
    end

    def write_stats
      home_attrs = { match: @match, team: @match.home_team }
      away_attrs = { match: @match, team: @match.away_team }
      home_stats = MatchStatistic.find_or_create_by(home_attrs)
      away_stats = MatchStatistic.find_or_create_by(away_attrs)
      all_stats.each do |stat|
        write_home_stat(home_stats, stat)
        write_away_stat(away_stats, stat)
      end
      success = home_stats.save && away_stats.save
      return true if success
      puts "#{home_stats.errors.full_messages}"
      puts "#{away_stats.errors.full_messages}"
      false
    end

    def write_home_stat(home_stats, stat)
      if home_stats.send(stat) == home_team_stat(stat)
        puts "home #{stat} is the same"
      else
        home_stats.update_attribute(stat, home_team_stat(stat))
      end
    end

    def write_away_stat(away_stats, stat)
      if away_stats.send(stat) == away_team_stat(stat)
        puts "away #{stat} is the same"
      else
        away_stats.update_attribute(stat, away_team_stat(stat))
      end
    end

    def stats
      return @stats unless @stats.blank?
      @stats = @page.search('.fi-stats')
    end

    def parse_stats(tr_num, splitter)
      statistic = stats.search('tr')[tr_num]
      return nil unless statistic
      statistic&.text&.downcase&.split(splitter)
    end

    def home_team_stat(stat)
      stat = send(stat)
      return nil unless stat&.length == 2
      stat.first&.strip&.to_i
    end

    def away_team_stat(stat)
      stat = send(stat)
      return nil unless stat&.length == 2
      stat.last&.strip&.to_i
    end

    def attempts_on_goal
      @attempts_on_goal ||= parse_stats(2, 'attempts')
    end

    def on_target
      @on_target ||= parse_stats(4, 'on-target')
    end

    def off_target
      @off_target ||= parse_stats(6, 'off-target')
    end

    def blocked
      @blocked ||= parse_stats(8, 'blocked')
    end

    def woodwork
      @woodwork ||= parse_stats(10, 'woodwork')
    end

    def corners
      @corners ||= parse_stats(12, 'corners')
    end

    def offsides
      @offsides ||= parse_stats(14, 'offsides')
    end

    def ball_possession
      @ball_possession ||= parse_stats(16, 'ball possession')
    end

    def pass_accuracy
      @pass_accuracy ||= parse_stats(18, 'pass accuracy')
    end

    def num_passes
      @num_passes ||= parse_stats(20, 'passes')
    end

    def passes_completed
      @passes_completed ||= parse_stats(22, 'passes completed')
    end

    def distance_covered
      @distance_covered ||= parse_stats(24, 'distance covered')
    end

    def balls_recovered
      @balls_recovered ||= parse_stats(26, 'balls recovered')
    end

    def tackles
      @tackles ||= parse_stats(28, 'tackles')
    end

    def blocks
      @blocks ||= parse_stats(30, 'blocks')
    end

    def clearances
      @clearances ||= parse_stats(32, 'clearances')
    end

    def yellow_cards
      @yellow_cards ||= parse_stats(34, 'yellow cards')
    end

    def red_cards
      @red_cards ||= parse_stats(36, 'red cards')
    end

    def second_yellow
      @second_yellow ||= parse_stats(38, 'second yellow card and red card')
    end

    def fouls_committed
      @fouls_committed ||= parse_stats(40, 'fouls committed')
    end
  end
end
