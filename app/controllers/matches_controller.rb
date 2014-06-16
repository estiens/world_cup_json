class MatchesController < ApplicationController

  def index
    @matches = Match.all.order(:match_number)
    render 'index.json.rabl'
  end

  def current
    @matches = Match.where(status: "live")
    render 'index.json.rabl'
  end

  def complete
    @matches = Match.where(status: "completed")
    render 'index.json.rabl'
  end

  def future
    @matches = Match.where(status: "future")
    render 'index.json.rabl'
  end

  def country
    @team = Team.where(fifa_code: params['fifa_code']).first
    @matches = Match.where("home_team_id = ? OR away_team_id = ?", @team.id, @team.id)
    render 'index.json.rabl'
  end

  def today
    @matches = Match.today
    render 'index.json.rabl'
  end

  def tomorrow
    @matches = Match.tomorrow
    render 'index.json.rabl'
  end
end


