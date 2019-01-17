class CreateTempCommitOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :temp_commit_offers do |t|
      t.string :program_name
      t.string :recruit_name
      t.string :position
      t.string :grad_year
      t.string :high_school
      t.string :state
      t.string :twitter_handle
      t.string :tweet_text
      t.string :tweet_permalink
      t.boolean :deleted

      t.timestamps
    end
  end
end
