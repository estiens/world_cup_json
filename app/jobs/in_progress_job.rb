class InProgressJob < ApplicationJob
  queue_as :current

  def perform
    scrape_in_progress
    scrape_soon_upcoming
    scrape_later_today
  end

  private

  def scrape_in_progress_match_details(matches)
    return unless matches.count.positive?

    Rails.logger.debug { "**SCHEDULER** Single Match Update for #{matches.count} scheduled matches" }
    matches.each do |match|
      MatchFetcher.scrape_for_scheduled_match(match)
      sleep(2)
      match.reload
      MatchWriter.new(match: match).write_match
    end
  end

  def scrape_match_details(matches)
    return if matches.count.zero?

    FetchDataForScheduledMatch.perform_later(matches.pluck(:id))
    MatchUpdateSelfJob.perform_later(matches.pluck(:id))
  end

  def in_progress_matches
    matches = Match.in_progress
    matches = Match.today.where.not(status: :completed) if matches.count.zero?
    matches.count.positive? ? matches : []
  end

  def scrape_in_progress
    matches = in_progress_matches
    return if matches.count.zero?

    msg = "Scrape In Progress: #{matches.first&.home_team&.country} vs #{matches.first&.away_team&.country}"
    Rails.logger.info(msg)
    scrape_in_progress_match_details(matches)
    self.class.set(wait: 30.seconds).perform_later
  end

  def scrape_soon_upcoming
    matches = Match.where('datetime < ?', 20.minutes.from_now).where(status: 'future_scheduled')

    scrape_match_details(matches)
  end

  def scrape_later_today
    matches = Match.where('datetime < ?', 1.day.from_now).where(status: 'future_scheduled')
                   .where('last_checked_at < ?', 5.minutes.ago)
    scrape_match_details(matches)
  end
end
