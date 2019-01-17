class Tag < ApplicationRecord
  include Hashid::Rails
  validates_uniqueness_of :name, scope: :group

  before_save :downcase_fields

  def media_list
    {
      count: media_tags.count,
      objects: media.as_json(only: [], methods: %i[id name created_at updated_at owner group file_name file_type size twitter_media_id urls])
    }
  end

  def has_media?
    Medium.tagged_with(name).any?
  end

  def downcase_fields
    name.downcase!
  end

  def as_json(options = {})
    super(options).merge(id: to_param)
  end
end
