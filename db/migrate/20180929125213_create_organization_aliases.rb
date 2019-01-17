class CreateOrganizationAliases < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_aliases do |t|
      t.references :organization, foreign_key: true
      t.string :alias

      t.timestamps
    end
  end
end
