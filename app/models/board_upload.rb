class BoardUpload < ApplicationRecord
  # include Mongoid::Document
  # field :user_id, type: String
  # field :board, type: Attachment
  # field :delete_boards, type: Mongoid::Boolean
  # field :delete_athletes, type: Mongoid::Boolean
  # field :requestor, type: Integer
  # field :processed, type: Mongoid::Boolean
  has_attached_file :board, path: "board_uploads/:user_id/:attachment/:id/:style/:filename"

  do_not_validate_attachment_file_type :board
  # validates_attachment :board, presence: true, content_type: { content_type: 'text/csv' }
  # validate :content_types
  #
  # def content_types
  #   errors.add(:object_content_type, 'invalid, only csv files allowed') unless csv_type?
  # end
  #
  # def csv_type?
  #   (board_content_type =~ /csv/).present?
  # end

  # Paperclip.interpolates :user_id do |attachment, style|
  #   attachment.instance.token
  # end

  def board_name
    board_file_name.gsub('_', ' ').gsub('-', ' ').gsub(/\..*/, '').titleize
  end

  def self.search(query)
    if query.present?
      where(
        arel_table[:board_file_name]
        .lower
        .matches("%#{query.downcase.to_s}%")
      )
    else
      all
    end
  end
end
