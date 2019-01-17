class AddNameToMessageRecipient < ActiveRecord::Migration[5.2]
  def change
    add_column :message_recipients, :name, :string
  end
end
