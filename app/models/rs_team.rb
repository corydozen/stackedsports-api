# TODO: DELETE

class RsTeam
  include Mongoid::Document

  store_in collection: 'Team'

  field :trialStartDate, type: Date

  field :_wperm, type: Array
  field :_rperm, type: Array
  field :_acl, type: Hash

  field :_created_at, type: DateTime
  field :_updated_at, type: DateTime
end
