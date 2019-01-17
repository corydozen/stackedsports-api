class AddColumnsToTeamTable < ActiveRecord::Migration[5.2]
  def change
    add_reference :teams, :messages, index: true, foreign_key: true
  end
end
