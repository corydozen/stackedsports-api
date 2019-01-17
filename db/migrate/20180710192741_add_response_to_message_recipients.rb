class AddResponseToMessageRecipients < ActiveRecord::Migration[5.2]
  def change
    add_column :message_recipients, :response, :string
  end
end
