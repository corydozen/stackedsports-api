class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :user, optional: true
end
