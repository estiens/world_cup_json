class AddCountryCodeToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :country_code, :string
  end
end
