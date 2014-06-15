class MatchesController < ApplicationController

  def index
    @matches = Match.all.order(:match_number)
  end

  def current
    @matches = Match.where(status: "live")
  end

  def past
  end


end


