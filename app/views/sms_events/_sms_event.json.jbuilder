json.extract! sms_event, :id, :created_at, :updated_at
json.url sms_event_url(sms_event, format: :json)
