class AddVerifiedByToTempCommitOffer < ActiveRecord::Migration[5.2]
  def change
    add_column :temp_commit_offers, :verified_by, :string
  end
end
