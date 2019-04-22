class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :password_confirmation, presence: true, on: :create
end