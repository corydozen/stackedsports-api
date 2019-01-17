class AddColumnsToMessageRecipients < ActiveRecord::Migration[5.2]
  def change
    add_reference :message_recipients, :platform, index: true, foreign_key: true
  end
end
