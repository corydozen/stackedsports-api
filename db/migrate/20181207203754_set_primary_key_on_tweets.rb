class SetPrimaryKeyOnTweets < ActiveRecord::Migration[5.2]
  def change
    add_index :tweets, :id, unique: true
  end
end
