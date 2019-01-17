class MoveSendAtFieldFromMessageToMessageRecipient < ActiveRecord::Migration[5.2]
  def change
    remove_column :messages, :send_at
    add_column :message_recipients, :send_at, :timestamp
  end
end
