# json.extract! user, :id, :first_name, :last_name, :email, :phone, :created_at, :updated_at
json.token Jwt::TokenProvider.call(user_id: user.id)
json.url api_user_url(user, format: :json)
