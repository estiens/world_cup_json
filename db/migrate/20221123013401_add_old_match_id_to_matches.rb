class AddOldMatchIdToMatches < ActiveRecord::Migration[7.0]
  def change
    add_column :matches, :old_match_id, :integer
  end
end
