class AddIsoCodeToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :iso_code, :string
  end
end
