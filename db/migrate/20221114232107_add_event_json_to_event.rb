class AddEventJsonToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :event_json, :text
    add_column :events, :extra_info, :text
  end
end
