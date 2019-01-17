class AddFootballSubdivisionToConference < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :football_subdivision, :string
  end
end
