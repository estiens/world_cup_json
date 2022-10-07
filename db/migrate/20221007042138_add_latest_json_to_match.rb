class AddLatestJsonToMatch < ActiveRecord::Migration[7.0]
  def change
    add_column :matches, :latest_json, :text
  end
end
