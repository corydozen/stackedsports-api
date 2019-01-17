class AddCommitAndOfferToTweet < ActiveRecord::Migration[5.2]
  def change
    add_column :tweets, :is_commit, :boolean, default: false
    add_column :tweets, :is_offer, :boolean, default: false
  end
end
