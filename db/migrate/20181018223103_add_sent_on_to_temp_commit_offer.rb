class AddSentOnToTempCommitOffer < ActiveRecord::Migration[5.2]
  def change
    add_column :temp_commit_offers, :sent_on, :datetime
  end
end
