class AddGroupingToTempCommitOffer < ActiveRecord::Migration[5.2]
  def change
    add_column :temp_commit_offers, :grouping, :string
  end
end
