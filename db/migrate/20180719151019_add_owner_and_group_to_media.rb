class AddOwnerAndGroupToMedia < ActiveRecord::Migration[5.2]
  def change
    add_column :media, :owner, :string
    add_column :media, :group, :string
  end
end
