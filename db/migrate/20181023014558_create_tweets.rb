class CreateTweets < ActiveRecord::Migration[5.2]
  def change
    create_table :tweets, id: false do |t|
      t.integer :id
      t.string :id_str
      t.string :created_at
      t.string :text
      t.boolean :truncated
      t.string :source
      t.integer :in_reply_to_status_id
      t.string :in_reply_to_status_id_str
      t.integer :in_reply_to_user_id
      t.string :in_reply_to_user_id_str
      t.string :in_reply_to_screen_name
      t.references :twitter_profile, foreign_key: true
      t.integer :quoted_status_id
      t.string :quoted_status_id_str
      t.boolean :is_quote_status
      t.integer :retweeted_status
      t.integer :quote_count
      t.integer :retweet_count
      t.integer :favorite_count
      t.boolean :possibly_sensitive
      t.string :filter_level
      t.string :hashtags
      t.string :urls
      t.string :user_mentions
      t.string :media
      t.string :symbols
      t.string :polls
      t.string :lang

      t.timestamps
    end
  end
end
