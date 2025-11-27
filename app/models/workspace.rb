class Workspace < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :users, through: :memberships

  before_create :set_invited_token

  validates :name, presence: true

  def owner_membership
    memberships.find_by(role: :owner)
  end

  def owner
    owner_membership&.user
  end

  private

  def set_invited_token
    self.invited_token ||= SecureRandom.hex(16)
  end
end
