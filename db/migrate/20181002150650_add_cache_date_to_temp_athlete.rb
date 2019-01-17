class AddCacheDateToTempAthlete < ActiveRecord::Migration[5.2]
  def change
    add_column :temp_athletes, :cache_date, :datetime, default: -> { 'CURRENT_TIMESTAMP' }, null: false 
  end
end
