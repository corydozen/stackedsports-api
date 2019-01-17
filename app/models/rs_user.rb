# TODO: DELETE

class RsUser
  include Mongoid::Document
  store_in collection: '_User'

  scope :has_twitter_account, -> { where(:twitterAccount.nin => ['', nil, {}]) }

  field :lastLogin, type: Date
  field :photoUrl, type: String
  field :fullName, as: :name, type: String
  field :email, type: String
  field :phone, type: String
  field :location, type: String
  field :salt, type: String

  field :username, type: String
  field :userPassword, type: String
  field :_hashed_password, type: String

  field :twitterAccount, type: Hash
  field :twitterId, type: String

  field :instagramAccount, type: Hash
  field :instagramId, type: String

  field :notifications, type: Hash

  field :resetExpires, type: String
  field :resetToken, type: String

  field :emailVerified, type: Boolean

  field :_wperm, type: Array
  field :_rperm, type: Array
  field :_acl, type: Hash

  field :_created_at, type: DateTime
  field :_updated_at, type: DateTime

  def team
    rst = RsTeam.find_by(_wperm: _id)
  end
end
