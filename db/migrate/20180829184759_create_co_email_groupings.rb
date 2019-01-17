class CreateCoEmailGroupings < ActiveRecord::Migration[5.2]
  def change
    create_table :co_email_groupings do |t|
      t.string :description

      t.timestamps
    end
  end
end
