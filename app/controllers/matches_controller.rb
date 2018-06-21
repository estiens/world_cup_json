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

  def show
    @match = Match.find_by!(fifa_id: params[:id])
    @matches = Match.where(id: @match.id)
    render_template
  end

  private

  def render_template
    if @details
      render 'index.json.rabl'
    else
      render 'summary.json.rabl'
    end
  end

  def order_by_params
    @matches = @matches.order('datetime ASC')
    @date = params[:by_date]
    @order_by = params[:by] || params[:order_by]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    order_and_limit
  end

  def order_and_limit
    order_by_date
    order_by_scores
    limit_to_days
  end

  def order_by_date
    return unless @date
    if @date.casecmp('DESC').zero?
      @matches = @matches.reorder(nil).order('datetime DESC')
    elsif @date.casecmp('ASC').zero?
      @matches = @matches.reorder(nil).order('datetime ASC')
    end
  end

  def limit_to_days
    return unless @start_date
    @matches = if @end_date
                 @matches.for_date(@start_date, @end_date)
               else
                 @matches.for_date(@start_date)
               end
  end

  def order_by_scores
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
