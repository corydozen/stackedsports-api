json.extract! conference, :id, :name, :created_at, :updated_at
json.url conference_url(conference, format: :json)
