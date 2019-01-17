class CreateUserSocialAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :user_social_accounts do |t|
      t.references :user, foreign_key: true
      t.references :platform, foreign_key: true
      t.string :platform_account_id
      t.string :oauth_token
      t.string :oauth_secret

      t.timestamps
    end
  end
end
