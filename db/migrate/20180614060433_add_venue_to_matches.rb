class AddVenueToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :venue, :string
    remove_column :matches, :match_number, :integer
  end
end
