class AddOauthTokenAndOauthSecretToMedium < ActiveRecord::Migration[5.2]
  def change
    add_column :media, :oauth_token, :string
    add_column :media, :oauth_secret, :string
  end
end
