class AddHeaderTextToCoEmailSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :co_email_settings, :header_text, :string
  end
end
