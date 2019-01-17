class AddNicknameAndMascotToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :nickname, :string
    add_column :organizations, :mascot, :string
  end
end
