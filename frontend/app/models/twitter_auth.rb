class TwitterAuth < ActiveRecord::Base
  belongs_to :user

  #validates :user_id, presence: true#, uniqueness: true
  validates :uid, presence: true, uniqueness: true
  validates :username, presence: true#, uniqueness: true
  validates :auth_token, presence: true#, uniqueness: true
  validates :auth_secret, presence: true#, uniqueness: true
  validate :one_per_user

  def active_model_serializer
    TwitterAuthSerializer
  end

  def serialize
    TwitterAuthSerializer.new(self, { root: false})
  end

  def serialized_json
    self.serialize.to_json
  end

  private

  def one_per_user
    if self.class.exists?(user_id: user_id, uid: uid) && self.id.nil?
      errors.add :user, 'already bound that account'
    end
  end
end
