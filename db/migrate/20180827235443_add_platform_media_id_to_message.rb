class AddPlatformMediaIdToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :platform_media_id, :string
    add_column :messages, :platform_media_status, :string
  end
end
