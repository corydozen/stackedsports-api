class AddPositionToAthlete < ActiveRecord::Migration[5.2]
  def change
    add_column :athletes, :position, :string
  end
end
