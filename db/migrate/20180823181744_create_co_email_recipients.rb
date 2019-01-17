class CreateCoEmailRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :co_email_recipients do |t|
      t.string :email
      t.string :full_name
      t.boolean :enabled

      t.timestamps
    end
  end
end
