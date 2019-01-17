class CreateTwitterUserRateLimits < ActiveRecord::Migration[5.2]
  def change
    create_table :twitter_user_rate_limits do |t|
      t.references :user, foreign_key: true
      t.datetime :myself
      t.datetime :users
      t.datetime :tweets
      t.datetime :followers
      t.datetime :friends
      t.datetime :favorites

      t.timestamps
    end
  end
end
