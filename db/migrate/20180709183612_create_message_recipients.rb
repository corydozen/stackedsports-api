class CreateMessageRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :message_recipients do |t|
      t.references :message, foreign_key: true
      t.string :recipient
      t.string :grouping
      t.string :platform

      t.timestamps
    end
  end
end
