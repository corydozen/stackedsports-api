class CreateBoardUpload < ActiveRecord::Migration[5.2]
  def change
    create_table :board_uploads do |t|
      t.string :user_id, null: false
      t.attachment :board, null: false
      t.boolean :delete_boards, default: false
      t.boolean :delete_athletes, default: false
      t.integer :requestor, null: false
      t.boolean :processed, default: false
    end
  end
end
