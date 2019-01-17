class AddSendAtToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :send_at, :timestamp
  end
end
