class User < ActiveRecord::Base
  belongs_to :promo_code, counter_cache: true

  has_one :account
  has_ancestry

  mount_uploader :avatar, AvatarUploader
  process_in_background :avatar, ReprocessAvatarWorker

  has_one :address
  has_one :favorite_team
  has_one :facebook_auth
  has_one :twitter_auth

  has_many :transactions, through: :account
  has_many :tickets
  has_many :mlb_tickets, class_name: 'Mlb::Ticket'
  has_many :nfl_tickets, class_name: 'Nfl::Ticket'

  has_many :mlb_contests, through: :mlb_tickets, class_name: 'Mlb::Contest', source: :contest
  has_many :nfl_contests, through: :nfl_tickets, class_name: 'Nfl::Contest', source: :contest

  validates :username, presence: true, uniqueness: true
  validates :account, presence: true
  validates :favorite_team, presence: true
  validates :platform, inclusion: { in: %w(android ios) }, allow_nil: true

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable

  accepts_nested_attributes_for :facebook_auth, allow_destroy: true
  accepts_nested_attributes_for :twitter_auth,  allow_destroy: true
  accepts_nested_attributes_for :address

  before_save :ensure_authentication_token
  before_validation :build_account, on: :create, unless: :account
  before_validation :build_favorite_team, on: :create

  include MLM
  include PromoCodeRedemption

  def to_s
    email
  end

  def account
    super || build_account
  end

  def contests(sport)
    assoc = :"#{sport.to_s.downcase}_contests"
    send(assoc)
  end

  def avatar_processing?
    !!avatar_processing && !Rails.env.test?
  end

  private

    def ensure_authentication_token
      if authentication_token.blank?
        self.authentication_token = loop do
          token = Devise.friendly_token
          break token unless User.exists?(authentication_token: token)
        end
      end
    end

end
