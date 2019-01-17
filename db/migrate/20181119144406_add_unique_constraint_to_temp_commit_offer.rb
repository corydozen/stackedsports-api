class AddUniqueConstraintToTempCommitOffer < ActiveRecord::Migration[5.2]
  def change
      add_index :temp_commit_offers, [:program_name, :recruit_name, :twitter_handle, :tweet_text, :keyword], unique: true, name: 'uniq_cols_idx'
  end
end
