class AddExtraInfo < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :extra_info, :text, if_not_exists: true
  end
end
