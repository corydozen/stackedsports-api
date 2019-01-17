class AlterColumnInMessageRecipientsTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :message_recipients, :platform_id, :platform_response_id
  end
end
