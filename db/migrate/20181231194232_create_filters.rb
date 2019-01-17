class CreateFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :filters do |t|
      t.references :user, foreign_key: true
      t.references :team, foreign_key: true
      t.boolean :is_shared, default: false, null: false
      t.string :name, null: false
      t.string :filterable_type, null: false
      t.string :criteria, null: false
      t.boolean :is_archived, default: false
      t.timestamps
    end
  end
end
