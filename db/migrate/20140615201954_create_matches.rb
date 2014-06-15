class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.string :fifa_id
      t.integer :match_number
      t.string :location
      t.datetime :datetime
      t.integer :home_team_id
      t.integer :away_team_id
      t.string :home_team_tbd
      t.string :away_team_tbd
      t.boolean :teams_scheduled
      t.integer :home_team_score
      t.integer :away_team_score
      t.string :location
      t.string :status
      t.timestamps
    end
  end
end
