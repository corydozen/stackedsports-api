class AddPrimaryAndSecondaryColorsToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :primary_color, :string
    add_column :organizations, :secondary_color, :string
  end
end
