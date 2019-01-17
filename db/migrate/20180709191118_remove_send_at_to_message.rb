class RemoveSendAtToMessage < ActiveRecord::Migration[5.2]
  def change
    remove_column :message_recipients, :send_at
  end
end
