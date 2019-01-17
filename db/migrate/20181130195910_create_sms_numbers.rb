class CreateSmsNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :sms_numbers do |t|
      t.string :name
      t.string :city
      t.string :state
      t.string :status
      t.bigint :number
      t.string :national_number
      t.string :bandwidth_id

      t.references :user, index: true, foreign_key: true

      t.timestamps
    end
  end
end
