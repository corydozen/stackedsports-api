class AddColumnsToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :sms_numbers, index: true
  end
end
