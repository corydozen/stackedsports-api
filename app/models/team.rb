class Team < ApplicationRecord
  include Hashid::Rails
  belongs_to :organization
  belongs_to :conference, optional: true
  has_many :users
  belongs_to :sport
  has_many :team_users
  has_many :users, through: :team_users
  has_many :team_athletes
  alias athletes team_athletes
  has_many :messages

  def tags
    Tag.where(group: id)
  end

  def self.search(query, org_id, conf_id)
    results = all
    if query.present? || org_id.present? || conf_id.present?
      results = where(
        arel_table[:name]
        .lower
        .matches("%#{query.downcase}%")
      )

      results = results.where(organization_id: org_id) if org_id.present?
      results = results.where(conference_id: conf_id) if conf_id.present?
    end

    results
  end

  def as_json(options = {})
    super(options).merge(id: to_param)
  end
end
