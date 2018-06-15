class AddLastUpdatedAtTimeStampsToMatch < ActiveRecord::Migration
  def change
    add_column :matches, :last_score_update_at, :datetime
    add_column :matches, :last_event_update_at, :datetime
  end
end
