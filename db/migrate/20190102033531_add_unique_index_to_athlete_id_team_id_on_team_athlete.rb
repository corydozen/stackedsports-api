class AddUniqueIndexToAthleteIdTeamIdOnTeamAthlete < ActiveRecord::Migration[5.2]
  def change
    add_index :team_athletes, %i[athlete_id team_id], unique: true, name: 'uniq_athlete_team_idx'
  end
end
