class SchedulerJob < ApplicationJob
  queue_as :scheduler

  # to do refine how often we grab in dif conditions
  SCRAPE_UNKNOWN_EVERY = 120.minutes
  SCRAPE_SCHEDULED_EVERY = 60.minutes
  SCRAPE_TODAY_EVERY = 1.minute
  SCRAPE_GENERAL_EVERY = 90.minutes

  def perform
    write_in_progress_matches
    scrape_scheduled_matches
    scrape_unscheduled_matches
    scrape_unknown_matches
    scrape_completed
  end

  def write_in_progress_matches
    matches = Match.in_progress
    ids = matches.pluck(:id)
    return unless ids.count.positive?

    ids.each do |id|
      FetchDataForScheduledMatch.perform_later(id)
      MatchUpdateSelfJob.perform_later(id)
    end
  end

  # ideally this has nothing
  def scrape_unknown_matches
    ids = Match.all.where('last_checked_at < ?', SCRAPE_UNKNOWN_EVERY.ago).pluck(:id)
    return unless ids.count.positive?

    Rails.logger.info("**SCHEDULER** unknown scrape for #{ids.count} matches")
    fetch_general_data_for_matches(ids)
  end

  def scrape_completed
    # may have events that come in after full-time will have to see
    Match.today.where(status: 'completed').where('last_checked_at < ?', SCRAPE_GENERAL_EVERY.ago).each do |match|
      FetchDataForScheduledMatch.perform_later(match.id)
      MatchUpdateSelfJob.perform_later(match.id)
    end
  end

  def update_anything_not_synced
    Match.where('last_changed_at < last_checked_at').where('updated_at < ?', 5.minutes.ago).each do |match|
      if match.latest_json.present?
        MatchUpdateSelfJob.perform_later(match.id)
      else
        scrape_match_details(match)
      end
    end
  end

  def fetch_general_data_for_matches(match_ids)
    return unless match_ids.count.positive?

    FetchGeneralDataForAllMatches.perform_later(match_ids)
  end

  def scrape_unscheduled_matches
    ids = Match.all.where(status: 'future_unscheduled').where('last_checked_at < ?',
                                                              SCRAPE_GENERAL_EVERY.ago).pluck(:id)
    Rails.logger.info("**SCHEDULER** (checking info for unscheduled matches) for #{ids.count} matches")
    fetch_general_data_for_matches(ids)

    ids = Match.all.where(datetime: nil).where('last_checked_at < ?', SCRAPE_GENERAL_EVERY.ago).pluck(:id)
    fetch_general_data_for_matches(ids)
  end

  def scrape_match_details(matches)
    return unless matches.count.positive?

    Rails.logger.info { "**SCHEDULER** Single Match Update for #{matches.count} scheduled matches" }
    matches.each { |match| FetchDataForScheduledMatch.perform_later(match.id) }
  end

  def scrape_scheduled_matches
    matches_to_scrape = Match.where('last_checked_at < ?', SCRAPE_SCHEDULED_EVERY.ago).where(status: 'future_scheduled')
    scrape_match_details(matches_to_scrape)
  end
end
