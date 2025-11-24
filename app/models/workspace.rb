class Workspace < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :users, through: :memberships

  validates :name, presence: true
end
