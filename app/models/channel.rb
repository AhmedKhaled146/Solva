class Channel < ApplicationRecord
  belongs_to :workspace
  has_many :messages, dependent: :destroy

  enum privacy: {
    public: "public",
    private: "private"
  }

  validates :name, presence: true
  validates :privacy, presence: true
end
