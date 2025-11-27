class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  has_many :memberships, dependent: :destroy
  has_many :workspaces, through: :memberships

  has_many :channel_memberships, dependent: :destroy
  has_many :channels, through: :channel_memberships

  has_many :messages, dependent: :destroy
  has_many :replies, dependent: :destroy
end
