class FetchGeneralDataForAllMatches < ApplicationJob
  queue_as :scraping

  def perform(match_ids)
    ids = MatchFetcher.scrape_for_general_info(match_ids)
    ids.each { |id| MatchUpdateSelfJob.perform_later(id) }
  end
end
