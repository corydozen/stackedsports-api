class CreateTwitterCacheDates < ActiveRecord::Migration[5.2]
  def change
    create_table :twitter_cache_dates do |t|
      t.references :athlete, foreign_key: true
      t.datetime :profile
      t.datetime :tweets
      t.datetime :followers
      t.datetime :favorites
      t.datetime :friends

      t.timestamps
    end
  end
end
