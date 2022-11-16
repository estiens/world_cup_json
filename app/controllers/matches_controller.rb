class MatchesController < BaseApiController
  before_action :detail_level
  before_action :load_matches, except: %i[show]

  def index
    @details = false unless params[:details]&.downcase == 'true'
    order_by_params
  end

  def current
    @matches = @matches.where(status: 'in progress')
    order_by_params
    render :index
  end

  def complete
    @matches = @matches.where(status: 'completed')
    order_by_params
    render :index
  end

  def future
    @matches = @matches.where(status: 'future')
    order_by_params
    render :index
  end

  def country
    @team = Team.where(country: params['country']&.upcase).first
    unless @team
      render json: { 'error': 'country code not_found' }
      return
    end
    @matches = @matches.where('home_team_id = ? OR away_team_id = ?', @team.id, @team.id)
    order_by_params
    render :index
  end

  def today
    @matches = @matches.today
    order_by_params
    render :index
  end

  def tomorrow
    @matches = @matches.tomorrow
    order_by_params
    render :index
  end

  def show
    @match = Match.find_by(fifa_id: params[:id]) || Match.find_by(id: params[:id])
  end

  private

  def load_matches
    @matches = Match.all
    @matches = @matches.includes(:match_statistics, :events) if @details
    @matches = @matches.order(datetime: :asc)
  end

  def order_by_params
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
      @matches = @matches.reorder(nil).order(Arel.sql('home_team_score + away_team_score DESC'))
    when 'home_team_goals'
      @matches = @matches.reorder(nil).order(Arel.sql('home_team_score DESC'))
    when 'away_team_goals'
      @matches = @matches.reorder(nil).order(Arel.sql('away_team_score DESC'))
    when 'closest_scores'
      @matches = @matches.reorder(nil).order(Arel.sql('abs(home_team_score - away_team_score) ASC'))
    end
  end

  def detail_level
    @details = params[:details] || 'true'
  end
end
