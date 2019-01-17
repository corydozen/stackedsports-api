class MessageRecipient < ApplicationRecord
  include Hashid::Rails
  belongs_to :message
  # belongs_to :platform
  # belongs_to :athlete

  def as_json(options = {})
    super(options).merge(id: to_param)
  end
end
