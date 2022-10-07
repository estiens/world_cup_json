class AddFlagToTeam < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :flag_url, :string
  end
end
