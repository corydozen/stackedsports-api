class MakeIdaBigIntOnTweets < ActiveRecord::Migration[5.2]
  def up
    change_column :tweets, :id, :integer, limit: 8
    change_column :tweets, :in_reply_to_status_id, :integer, limit: 8
    change_column :tweets, :in_reply_to_user_id, :integer, limit: 8
    change_column :tweets, :quoted_status_id, :integer, limit: 8
  end

  def down
    change_column :tweets, :id, :integer
    change_column :tweets, :in_reply_to_status_id, :integer
    change_column :tweets, :in_reply_to_user_id, :integer
    change_column :tweets, :quoted_status_id, :integer
  end
end
