class AddSportToTeam < ActiveRecord::Migration[5.2]
  def change
    add_reference :teams, :sport, foreign_key: true
  end
end
