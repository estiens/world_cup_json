class StaticController < ApplicationController
  def index
    @today_matches = Match.today
    @tomorrow_matches = Match.tomorrow
  end
end
