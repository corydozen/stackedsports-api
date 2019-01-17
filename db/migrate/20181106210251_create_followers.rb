class CreateFollowers < ActiveRecord::Migration[5.2]
  def change
    create_table :followers do |t|
      t.references :twitter_profile, foreign_key: true
      t.references :follower, index: true, foreign_key: {to_table: :twitter_profiles}
      t.datetime :unfollow_date

      t.timestamps
    end

    add_index :followers, [:twitter_profile_id, :follower_id], unique: true
  end
end
