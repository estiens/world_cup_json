class AddFlagToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :flag_url, :string
  end
end
