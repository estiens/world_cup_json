# frozen_string_literal: true

class MatchesController < BaseApiController
  before_action :detail_level

  def index
    @matches = Match.all.order('datetime ASC')
    order_by_params
    render_template
  end

  def current
    @matches = Match.where(status: 'in progress')
    order_by_params
    render_template
  end

  def complete
    @matches = Match.where(status: 'completed')
    order_by_params
    render_template
  end

  def future
    @matches = Match.where(status: 'future')
    order_by_params
    render_template
  end

  def country
    @team = Team.where(fifa_code: params['fifa_code']&.upcase).first
    unless @team
      respond_with "{'error': 'country code not_found'}", status: :not_found
      return
    end
    @matches = @team.matches
    order_by_params
    render_template
  end

  def today
    @matches = Match.today
    order_by_params
    render_template
  end

  def tomorrow
    @matches = Match.tomorrow
    order_by_params
    render_template
  end

  private

  def render_template
    if @details
      render 'index.json.rabl', callback: params['callback']
    else
      render 'summary.json.rabl', callback: params['callback']
    end
  end

  def order_by_params
    @matches = @matches.order('datetime DESC')
    @date = params[:by_date]
    @order_by = params[:by]
    order_by_date
    order_by_desc
  end

  def order_by_date
    return unless @date
    if @date.casecmp('DESC').zero?
      @matches = @matches.reorder(nil).order('datetime DESC')
    elsif @date.casecmp('ASC').zero?
      @matches = @matches.reorder(nil).order('datetime ASC')
    end
  end

  def order_by_desc
    return unless @order_by
    case @order_by.downcase
    when 'total_goals'
      @matches = @matches.reorder(nil).order('home_team_score + away_team_score DESC')
    when 'home_team_goals'
      @matches = @matches.reorder(nil).order('home_team_score DESC')
    when 'away_team_goals'
      @matches = @matches.reorder(nil).order('away_team_score DESC')
    when 'closest_scores'
      @matches = @matches.reorder(nil).order('abs(home_team_score - away_team_score) ASC')
    end
  end

  def detail_level
    @details = params['details'] != 'false'
  end
end
