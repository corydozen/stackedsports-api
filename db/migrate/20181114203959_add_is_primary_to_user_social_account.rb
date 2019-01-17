class AddIsPrimaryToUserSocialAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :user_social_accounts, :is_primary, :boolean, default: false
  end
end
