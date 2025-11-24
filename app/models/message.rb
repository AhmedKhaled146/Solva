class Message < ApplicationRecord
  belongs_to :user
  belongs_to :channel
  has_many :replies, dependent: :destroy

  validates :body, presence: true
end
