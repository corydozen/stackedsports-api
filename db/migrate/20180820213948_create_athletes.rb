class CreateAthletes < ActiveRecord::Migration[5.2]
  def change
    create_table :athletes do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.string :nick_name
      t.string :graduation_year
      t.string :high_school
      t.string :state
      t.string :coach_name
      t.string :mothers_name
      t.string :fathers_name
      t.string :hudl_id
      t.string :arms_id
      t.string :twitter_profile_id
      t.string :instagram_id
      t.references :team, foreign_key: true

      t.timestamps
    end
  end
end
