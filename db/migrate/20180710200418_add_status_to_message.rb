class AddStatusToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :status, :string, default: 'Pending'
  end
end
