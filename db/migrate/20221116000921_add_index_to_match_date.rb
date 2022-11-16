class AddIndexToMatchDate < ActiveRecord::Migration[7.0]
  def change
    add_index :matches, :datetime
  end
end
