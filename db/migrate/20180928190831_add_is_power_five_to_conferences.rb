class AddIsPowerFiveToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :is_power_five, :boolean, default: false
  end
end
