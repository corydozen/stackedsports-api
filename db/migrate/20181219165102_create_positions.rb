class CreatePositions < ActiveRecord::Migration[5.2]
  def change
    create_table :positions do |t|
      t.string :name
      t.string :abbreviation
      t.string :standardized_name
      t.string :role
      t.string :alternate_names

      t.timestamps
    end
  end
end
