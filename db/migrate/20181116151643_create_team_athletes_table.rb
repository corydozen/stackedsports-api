class CreateTeamAthletesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :team_athletes do |t|

      t.string :first_name
      t.string :last_name
      t.string :nick_name
      t.string :phone_number
      t.string :email
      t.string :high_school
      t.string :state
      t.string :coach_name
      t.string :mothers_name
      t.string :fathers_name
      t.string :positions

      t.date :graduation_year

      t.timestamps

      t.belongs_to :athlete, foreign_key: true, index: true
      t.belongs_to :team, foreign_key: true, index: true

    end
  end
end
