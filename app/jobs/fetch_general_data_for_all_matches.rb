class FetchGeneralDataForAllMatches < ApplicationJob
  queue_as :scraping

  def perform(match_ids)
    matches = Match.where(id: match_ids)
    new_json_ids = MatchFetcher.scrape_for_general_info(matches)
    new_json_ids.each { |id| MatchUpdateSelfJob.perform_later(id) }
  end
end
