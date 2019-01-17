class AddOrganizationToTempCommitOffer < ActiveRecord::Migration[5.2]
  def change
    add_reference :temp_commit_offers, :organization, foreign_key: true
  end
end
