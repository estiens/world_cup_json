class AddTeamIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :team_id, :integer
  end
end
