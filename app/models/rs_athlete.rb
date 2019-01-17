# TODO: DELETE

class RsAthlete
  include Mongoid::Document
  store_in collection: 'Athlete'

  field :name, type: String
  field :nickname, type: String
  field :phone, type: String
  field :email, type: String
  field :grad_year, type: String
  field :high_school, type: String
  field :positions, type: String
  field :photoUrl, type: String
  field :_created_at, type: DateTime
  field :_updated_at, type: DateTime
  field :_p_team, type: String
  field :_wperm, type: Array
  field :_rperm, type: Array
  field :_acl, type: Hash
  field :boards, type: Array
  field :twitterProfileV11, type: Hash
  field :twitterProfile, type: Hash
  field :instagramProfile, type: Hash
  field :lastUpdateReason, type: Hash
  field :notes, type: Hash
end
