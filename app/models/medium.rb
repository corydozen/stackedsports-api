class Medium < ApplicationRecord
  has_many :messages
  belongs_to :user, foreign_key: 'owner'
  include Hashid::Rails
  acts_as_taggable
  has_attached_file :object,
    styles: ->(f) { f.instance.check_file_type }

  do_not_validate_attachment_file_type :object
  validate :content_types

  validate :only_mp4_videos
  validate :ojbect_size_valid

  def messages
    msgs = Message.where(media_id: id).as_json(only: [], methods: %i[
                                                 id body created_at updated_at next_send_at current_status recipients
                                               ])

    { count: msgs.count, list: msgs }
  end

  def has_been_sent?
    has_been_sent = Message.where(media_id: id).where.not(status: 'Pending').limit(1)
    has_been_sent.present?
  end

  def tags_list
    # Return a unique list of tags on the record
    tags.map(&:name).join(',')
  end

  # NOTE: Overriding some attribute names for display purposes
  def file_name
    object_file_name
  end

  def file_type
    object_content_type
  end

  def size
    object_file_size
  end

  def urls
    if image_type? || gif_type?
      {
        'thumb' => object.url(:thumb),
        'medium' => object.url(:medium),
        'original' => object.url
      }
    elsif video_type?
      {
        'thumb' => object.url(:thumb),
        'medium' => object.url(:medium),
        'original' => object.url
      } if video_type?
    else
      {}
    end
  end

  # NOTE: method for file type check to produce different style based on file

  def check_file_type
    if image_type? || gif_type?
      {
        thumb: '200x200>',
        medium: '500x500>'
      }
    elsif video_type?
      {
        thumb: { geometry: '200x200>' , format: 'jpg', frame_index: 2 },
        medium: { geometry: '500x500>' , format: 'jpg', frame_index: 2 }
      }
    elsif pdf_type?
      {
        thumb: ['200x200>', :png],
        medium: ['500x500>', :png]
      }
    else
      {}
    end
  end




  def ojbect_size_valid
    errors.add(:object_file_size, 'should be less than or equal to 5MB for images') if object_file_size > 5.megabytes && image_type?
    errors.add(:object_file_size, 'should be less than or equal to 15MB for gifs and videos') if object_file_size > 15.megabytes && (gif_type? || video_type?)
  end

  def content_types
    errors.add(:object_content_type, 'invalid, only images, gifs, and videos allowed') unless video_type? || gif_type? || image_type?
  end

  def only_mp4_videos
    errors.add(:object_content_type, 'currently only supports MP4 video') if video_type? && !is_mp4?
  end

  def image_type?
    object_content_type =~ /jpeg/ || object_content_type =~ /jpg/ || object_content_type =~ /png/
  end

  def gif_type?
    (object_content_type =~ /gif/).present?
  end

  def video_type?
    (object_content_type =~ /video/).present?
  end

  def is_mp4?
    video_type? && (object_file_name =~ /mp4/).present?
  end

  def pdf_type?
    (object_content_type =~ /pdf/).present?
  end

  def as_json(options = {})
    super(options).merge(id: to_param)
  end
end
