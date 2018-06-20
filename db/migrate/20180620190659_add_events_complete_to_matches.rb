class AddEventsCompleteToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :events_complete, :boolean, null: false, default: false
  end
end
