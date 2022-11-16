class InProgressJob < ApplicationJob
  queue_as :scheduler

  def perform
    scrape_in_progress
    scrape_soon_upcoming
    scrape_later_today

    # we want to scrape ev 30 seconds for in progress
    # but cron only has 1 min resolution
    sleep(30)
    scrape_in_progress
  end

  private

  def scrape_match_details(matches)
    return unless matches.count.positive?

    Rails.logger.debug { "**SCHEDULER** Single Match Update for #{matches_to_scrape.count} scheduled matches" }
    matches.each { |match| FetchDataForScheduledMatch.perform_later(match.id) }
  end

  def scrape_in_progress
    scrape_match_details(Match.in_progress)
  end

  def scrape_soon_upcoming
    matches = Match.where('datetime < ?', 20.minutes.from_now).where(status: 'future_scheduled')
                   .where('last_checked_at < ?', 1.minute.ago)
    scrape_match_details(matches)
  end

  def scrape_later_today
    matches = Match.where('datetime < ?', 1.day.from_now).where(status: 'future_scheduled')
                   .where('last_checked_at < ?', 5.minutes.ago)
    scrape_match_details(matches)
  end
end
