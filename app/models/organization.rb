class Organization < ApplicationRecord
  include Hashid::Rails
  has_attached_file :logo, styles: { medium: '300x300>', thumb: '100x100>' }, default_url: '/images/:style/missing.png'
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\z/

  has_many :teams

  def self.search(query)
    if query.present?
      where(
        arel_table[:name]
        .lower
        .matches("%#{query.downcase}%")
      )
        .or(where(arel_table[:address]
        .lower
        .matches("%#{query.downcase}%")))
        .or(where(arel_table[:city]
        .lower
        .matches("%#{query.downcase}%")))
        .or(where(arel_table[:state]
        .lower
        .matches("%#{query.downcase}%")))
        .or(where(arel_table[:zip]
        .lower
        .matches("%#{query.downcase}%")))
        .or(where(arel_table[:phone]
        .lower
        .matches("%#{query.downcase}%")))
    else
      all
    end
  end

  def as_json(options = {})
    super(options).merge(id: to_param)
  end
end
