class MatchesController < ApplicationController

  def ordered_class
    klass = Match
    if params[:by_date].present? && params[:by_date].upcase == 'DESC'
      klass.order('datetime DESC')
    elsif params[:by_date].present? && params[:by_date].upcase == 'ASC'
      klass.order('datetime ASC')
    else
      klass.order(:match_number)
    end
  end

  def index
    @matches = ordered_class.all
    @home_team_events = Event.select{|event| event.home_team == true}
    render 'index.json.rabl'
  end

  def current
    @matches = ordered_class.where(status: "in progress")
    render 'index.json.rabl'
  end

  def complete
    @matches = ordered_class.where(status: "completed")
    render 'index.json.rabl'
  end

  def future
    @matches = ordered_class.where(status: "future")
    render 'index.json.rabl'
  end

  def country
    @team = Team.where(fifa_code: params['fifa_code']).first
    @matches = ordered_class.where("home_team_id = ? OR away_team_id = ?", @team.id, @team.id)
    render 'index.json.rabl'
  end

  def today
    @matches = ordered_class.today
    render 'index.json.rabl'
  end

  def tomorrow
    @matches = ordered_class.tomorrow
    render 'index.json.rabl'
  end
end


