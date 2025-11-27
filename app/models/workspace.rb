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

  def membership_for(user)
    memberships.find_by(user: user)
  end

  def role_for(user)
    membership_for(user)&.role
  end

  def role_owner?(user)
    role_for(user) == "owner"
  end

  def role_admin?(user)
    role_for(user) == "admin"
  end

  def role_member?(user)
    role_for(user) == "member"
  end

  private

  def set_invited_token
    self.invited_token ||= SecureRandom.hex(16)
  end
end
