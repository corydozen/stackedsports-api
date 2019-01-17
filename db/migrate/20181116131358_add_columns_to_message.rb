class AddColumnsToMessage < ActiveRecord::Migration[5.2]
  def change
    add_reference :messages, :team, index: true
    add_reference :messages, :users, index: true
  end
end
