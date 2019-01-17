json.extract! organization, :id, :name, :phone, :address, :address_2, :city, :state, :zip, :stripe_customer_id, :created_at, :updated_at
json.url api_organization_url(organization, format: :json)
