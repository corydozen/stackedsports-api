class AddOauthFieldsToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :oauth_token, :string
    add_column :messages, :oauth_secret, :string
  end
end
