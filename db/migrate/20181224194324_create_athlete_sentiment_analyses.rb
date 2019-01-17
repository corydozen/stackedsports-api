class CreateAthleteSentimentAnalyses < ActiveRecord::Migration[5.2]
  def change
    create_table :athlete_sentiment_analyses do |t|
      t.datetime :as_of
      t.references :athlete, foreign_key: true
      t.float :mixed, default: 0
      t.float :negative, default: 0
      t.float :neutral, default: 0
      t.float :positive, default: 0
      t.string :sentiment

      t.timestamps
    end
  end
end
