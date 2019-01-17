class Conference < ApplicationRecord
  has_many :organizations

  def self.search(query)
    if query.present?
      where(
        arel_table[:name]
        .lower
        .matches("%#{query.downcase.to_s}%")
      )
    else
      all
    end
  end
end
