class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :workspace

  enum role: {
    owner: 0,
    admin: 1,
    member: 2
  }

  validates :role, presence: true
end
