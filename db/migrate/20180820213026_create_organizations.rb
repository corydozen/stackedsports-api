class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :phone
      t.string :address
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :stripe_customer_id

      t.timestamps
    end
  end
end
