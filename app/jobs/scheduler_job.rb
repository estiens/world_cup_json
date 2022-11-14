class SchedulerJob < ApplicationJob
  queue_as :scheduler

  # to do refine how often we grab in dif conditions
  SCRAPE_UNKNOWN_EVERY = 120.minutes
  SCRAPE_SCHEDULED_EVERY = 60.minutes
  SCRAPE_TODAY_EVERY = 1.minute
  SCRAPE_GENERAL_EVERY = 90.minutes

  # ideally this has nothing
  def scrape_unknown_matches
    ids = Match.all.where('last_checked_at < ?', SCRAPE_UNKNOWN_EVERY.ago).pluck(:id)
    Rails.logger.warn("**SCHEDULER** unknown scrape for #{ids.count} matches")
    return unless ids.count.positive?

    FetchGeneralDataForAllMatches.perform_later(ids)
  end

  def scrape_unscheduled_matches
    ids = Match.all.where(status: 'future_unscheduled').where('last_checked_at < ?',
                                                              SCRAPE_GENERAL_EVERY.ago).pluck(:id)
    Rails.logger.info("**SCHEDULER** (checking info for unscheduled matches) for #{ids.count} matches")
    return unless ids.count.positive?

    FetchGeneralDataForAllMatches.perform_later(ids)
  end

  def scrape_match_details(matches)
    return unless matches.count.positive?

    Rails.logger.debug { "**SCHEDULER** Single Match Update for #{matches_to_scrape.count} scheduled matches" }
    matches.each { |match| FetchDataForScheduledMatch.perform_later(match.id) }
  end

  def scrape_scheduled_matches
    today_matches = Match.today.where('last_checked_at < ?', SCRAPE_TODAY_EVERY.ago)
    scrape_match_details(today_matches)
    sleep(5)
    matches_to_scrape = Match.where('last_checked_at < ?', SCRAPE_SCHEDULED_EVERY.ago).where(status: 'future_scheduled')
    scrape_match_details(matches_to_scrape)
  end

  def perform
    scrape_scheduled_matches
    scrape_unscheduled_matches
  end
end
