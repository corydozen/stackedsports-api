class AddColumnsToAthleteTable < ActiveRecord::Migration[5.2]
  def change
    add_reference :message_recipients, :athlete, index: true, foreign_key: true
  end
end
