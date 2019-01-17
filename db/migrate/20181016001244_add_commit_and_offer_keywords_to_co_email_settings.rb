class AddCommitAndOfferKeywordsToCoEmailSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :co_email_settings, :commit_keywords, :string
    add_column :co_email_settings, :offer_keywords, :string
  end
end
