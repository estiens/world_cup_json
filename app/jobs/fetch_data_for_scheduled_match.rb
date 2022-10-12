class FetchDataForScheduledMatch < ApplicationJob
  queue_as :scraping

  def perform(match_id)
    match = Match.find(match_id)
    result = MatchFetcher.scrape_for_scheduled_match(match)
    result ? MatchUpdateSelfJob.perform_later(match.id) : false
  end
end
