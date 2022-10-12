class AllMatchesService
  def self.setup
    return true if Match.count == 64

    fixtures = MatchFetcher.all_matches
    return false unless fixtures.is_a?(Array)

    Match.destroy_all
    fixtures.each { |fixture| MatchWriter.setup_match(fixture) }
    if Match.count == 64
      Rails.logger.info 'All matches setup!'
    else
      Rails.logger.info 'Something went wrong with match setup'
    end
  end

  def self.sync
    # TODO
  end
end
