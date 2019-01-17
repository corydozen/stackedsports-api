class AddSentAtAndStatusToMessageRecipients < ActiveRecord::Migration[5.2]
  def change
    add_column :message_recipients, :sent_at, :timestamp
    add_column :message_recipients, :status, :string, default: 'pending'
  end
end
