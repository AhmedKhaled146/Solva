class Channel < ApplicationRecord
  belongs_to :workspace
  has_many :messages, dependent: :destroy

  has_many :channel_memberships, dependent: :destroy
  has_many :users, through: :channel_memberships

  enum :privacy, { public: "public", private: "private" }, default: :public, prefix: true # privacy_public? or privacy_private?

  validates :name, presence: true
  validates :privacy, presence: true
end
