json.extract! team, :id, :name, :photo_url, :phone, :trial_start_date, :override_plan_id, :organization_id, :stripe_subscription_id, :created_at, :updated_at
json.url team_url(team, format: :json)
