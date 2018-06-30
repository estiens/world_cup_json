class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.string :position
      t.integer :team_id
      t.integer :goals

      t.timestamps null: false
    end
  end
end
