class User < ApplicationRecord
  has_many :posts

  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :password_confirmation, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :update, unless: lambda { |user| user.password.blank? }

  def self.find_by_token(bearer_token)
    user_id = JsonWebToken.decode(bearer_token)[:user_id]
    User.find(user_id) unless user_id.nil?
  end
end