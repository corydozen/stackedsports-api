# TODO: DELETE

class RsBoard
  include Mongoid::Document
  store_in collection: 'Board'

  field :_id, type: String
  field :athleteRefs, type: Array
  field :activityRefs, type: Array
  field :lastUpdateReason, type: Hash
  field :name, type: String
  field :description, type: String
  field :_created_at, type: DateTime
  field :_updated_at, type: DateTime
  field :_p_team, type: String
  field :_wperm, type: Array
  field :_rperm, type: Array
  field :_acl, type: Hash
end
