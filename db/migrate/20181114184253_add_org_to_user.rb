class AddOrgToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :organization, :string
  end
end
