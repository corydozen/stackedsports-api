class AddPlatformIdToMessageRecipient < ActiveRecord::Migration[5.2]
  def change
    add_column :message_recipients, :platform_id, :string
  end
end
