class MediaTag < ApplicationRecord
  belongs_to :medium
  belongs_to :tag
end
