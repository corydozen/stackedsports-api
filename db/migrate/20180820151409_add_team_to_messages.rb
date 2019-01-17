class AddTeamToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :team, :string
  end
end
