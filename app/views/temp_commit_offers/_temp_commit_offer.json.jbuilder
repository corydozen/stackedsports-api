json.extract! temp_commit_offer, :id, :program_name, :recruit_name, :position, :grad_year, :high_school, :state, :twitter_handle, :tweet_text, :tweet_permalink, :deleted, :created_at, :updated_at
json.url temp_commit_offer_url(temp_commit_offer, format: :json)
