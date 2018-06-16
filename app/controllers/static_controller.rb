class StaticController < ApplicationController
  def index
    @teams = Team.all
    @matches = Match.all
    @today_matches = Match.today
    @tomorrow_matches = Match.tomorrow
  end
end
