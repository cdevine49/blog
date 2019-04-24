class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable

  validates :user, presence: true
  validates :title, presence: true
  validates :body, presence: true

  default_scope { order(created_at: :desc) }
end