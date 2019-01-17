class AddSendAtToMessageRecipient < ActiveRecord::Migration[5.2]
  def change
    add_column :message_recipients, :send_at, :timestamp
  end
end
