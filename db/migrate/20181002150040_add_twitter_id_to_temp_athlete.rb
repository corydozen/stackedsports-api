class AddTwitterIdToTempAthlete < ActiveRecord::Migration[5.2]
  def change
    add_column :temp_athletes, :twitter_id, :string
  end
end
