class CreateTempAthletes < ActiveRecord::Migration[5.2]
  def change
    create_table :temp_athletes do |t|
      t.string :description
      t.integer :grad_year
      t.string :positions
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :state
      t.string :city
      t.string :zip_code
      t.string :twitter_handle
      t.string :mobile
      t.string :email
      t.string :hs_name
      t.string :hs_state
      t.integer :priority, default: -1
      t.boolean :ignore, default: false

      t.timestamps
    end
  end
end
