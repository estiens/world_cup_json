class TeamsController < BaseApiController
  def index
    @teams = Team.all
    render 'team_index.json.rabl', callback: params['callback']
  end

  def results
    @teams = Team.all
    limit_team_if_requested
    render 'team_results.json.rabl', callback: params['callback']
  end

  def group_results
    @groups = Group.all
    limit_group_if_requested
    render 'group_results.json.rabl', callback: params['callback']
  end

  private

  def limit_team_if_requested
    return nil unless params[:team_id] || params[:fifa_code]
    team = Team.where(id: params[:team_id])
    team = Team.where(fifa_code: params[:fifa_code]&.upcase) if team.empty?
    raise ActiveRecord::RecordNotFound, 'Team Not Found' if team.empty?
    @teams = team
  end

  def limit_group_if_requested
    return nil unless params[:group_id]
    group_id = params[:group_id]
    group = Group.where(letter: group_id)
    group = Group.where(id: group_id.to_i) if group.empty?
    raise ActiveRecord::RecordNotFound, 'Group Not Found' if group.empty?
    @groups = group
  end
end
