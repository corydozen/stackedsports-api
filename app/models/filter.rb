class Filter < ApplicationRecord
  include Hashid::Rails
  belongs_to :user
  belongs_to :team

  validates :name, :criteria, :user, :team, :filterable_type, presence: true

  scope :is_private, -> { where(is_shared: false) }
  scope :is_public, -> { where(is_shared: true) }

  def as_json(options = {})
    super(options).merge(id: to_param)
  end
end
