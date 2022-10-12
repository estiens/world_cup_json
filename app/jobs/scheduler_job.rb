class SchedulerJob < ApplicationJob
  queue_as :scheduler

  # to do refine how often we grab in dif conditions
  SCRAPE_UNKNOWN_EVERY = 120.minutes
  SCRAPE_SCHEDULED_EVERY = 60.minutes
  SCRAPE_GENERAL_EVERY = 90.minutes

  # ideally this has nothing
  def scrape_unknown_matches
    ids = Match.all.where('updated_at > ?', SCRAPE_UNKNOWN_EVERY.ago).pluck(:id)
    Rails.logger.info("**SCHEDULER** unknown scrape for #{ids.count} matches")
    return unless ids.count.positive?

    FetchGeneralDataForAllMatches.perform_later(ids)
  end

  def scrape_unscheduled_matches
    ids = Match.all.where(status: 'future_unscheduled').where('updated_at > ?', SCRAPE_GENERAL_EVERY.ago).pluck(:id)
    Rails.logger.info("**SCHEDULER** unknown scrape for #{ids.count} matches")
    return unless ids.count.positive?

    FetchGeneralDataForAllMatches.perform_later(ids)
  end

  def scrape_scheduled_matches
    matches_to_scrape = Match.where('updated_at > ?', SCRAPE_SCHEDULED_EVERY.ago).where(status: 'future_scheduled')
    Rails.logger.info("**SCHEDULER** Single Match Update for #{matches_to_scrape.count} scheduled matches")
    matches_to_scrape.each do |match|
      FetchDataForScheduledMatch.perform_later(match.id)
    end
  end

  def update_matches
    # shouldn't get out of sync now, but we can catch up if it does without scraping again
    matches = Match.needs_updated
    return unless matches.count.positive?

    Rails.logger.info("**SCHEDULER** #{Match.needs_updated.count} matches out of sync")
    matches.each { |match| MatchUpdateSelfJob.perform_later(match.id) }
  end

  def perform
    scrape_unscheduled_matches
    scrape_scheduled_matches
    sleep(5)
    update_matches
  end
end
