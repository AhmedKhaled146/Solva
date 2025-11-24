class Reply < ApplicationRecord
  belongs_to :message
  belongs_to :user

  validates :body, presence: true
  validates :message, presence: true
  validates :user, presence: true
end
