class AddKeywordDefaultsToTempCommitOffer < ActiveRecord::Migration[5.2]
  def change
    change_column :temp_commit_offers, :grouping, :string, default: 'Other Commitments'
  end
end
