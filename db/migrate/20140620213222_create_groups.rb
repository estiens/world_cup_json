class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :letter, null: false
      t.timestamps
    end
  end
end
