json.extract! athlete, :id, :first_name, :last_name, :phone, :email, :nick_name, :graduation_year, :high_school, :state, :coach_name, :mothers_name, :fathers_name, :hudl_id, :arms_id, :twitter_profile_id, :instagram_id, :team_id, :created_at, :updated_at
json.url athlete_url(athlete, format: :json)
