class AddConferenceToTeam < ActiveRecord::Migration[5.2]
  def change
    add_reference :teams, :conference, foreign_key: true
    remove_reference :organizations, :conference
  end
end
