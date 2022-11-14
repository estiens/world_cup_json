class MatchInProgress < ApplicationJob
  queue_as :scheduler

  def perform
    matches = Match.in_progress
    return unless matches.count.positive?

    Rails.logger.debug { "**SCHEDULER** #{matches.count} matches in progress, scraping" }
    matches.each { |match| FetchDataForScheduledMatch.perform_later(match.id) }
  end
end
