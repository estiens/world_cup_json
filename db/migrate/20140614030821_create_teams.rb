class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :country
      t.string :alternate_name
      t.string :fifa_code
      t.integer :group_id
      t.integer :wins
      t.integer :draws
      t.integer :losses
      t.integer :goals_for
      t.integer :goals_against
      t.boolean :knocked_out

      t.timestamps
    end
  end
end
