json.extract! board_upload, :id, :user_id, :board, :delete_boards, :delete_athletes, :requestor, :processed, :created_at, :updated_at
json.url board_upload_url(board_upload, format: :json)
