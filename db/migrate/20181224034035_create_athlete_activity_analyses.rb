class CreateAthleteActivityAnalyses < ActiveRecord::Migration[5.2]
  def change
    create_table :athlete_activity_analyses do |t|
      t.datetime :as_of
      t.string :dow
      t.references :athlete, foreign_key: true
      t.integer :tweets, default: 0
      t.integer :retweets, default: 0
      t.integer :likes, default: 0

      t.timestamps
    end
  end
end
