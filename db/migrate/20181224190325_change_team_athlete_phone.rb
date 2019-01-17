class ChangeTeamAthletePhone < ActiveRecord::Migration[5.2]
  def change
    rename_column :team_athletes, :phone_number, :phone
  end
end
