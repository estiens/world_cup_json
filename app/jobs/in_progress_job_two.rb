class InProgressJobTwo < ApplicationJob
  queue_as :current

  def perform
    sleep(rand(20..40))
    scrape_in_progress
    scrape_soon_upcoming
  end

  private

  def scrape_match_details(matches)
    return unless matches.count.positive?

    Rails.logger.debug { "**SCHEDULER** Single Match Update for #{matches.count} scheduled matches" }
    matches.each do |match|
      MatchUpdateSelfJob.perform_later(match.id)
      FetchDataForScheduledMatch.perform_later(match.id)
    end
  end

  def scrape_in_progress
    scrape_match_details(Match.in_progress)
  end

  def scrape_soon_upcoming
    matches = Match.where('datetime < ?', 20.minutes.from_now).where(status: 'future_scheduled')

    scrape_match_details(matches)
  end
end
