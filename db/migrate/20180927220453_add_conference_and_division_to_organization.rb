class AddConferenceAndDivisionToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_reference :organizations, :conference, foreign_key: true
    add_column :organizations, :division, :string
  end
end
