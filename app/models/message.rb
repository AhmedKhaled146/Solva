class Message < ApplicationRecord
  belongs_to :user
  belongs_to :channel
  has_many :replies, dependent: :destroy

  after_create_commit -> {
    broadcast_append_to(
      "channel_#{channel_id}",
      partial: "messages/message",
      locals: { message: self, current_user: user },
      target: "messages"
    )
    broadcast_remove_to(
      "channel_#{channel_id}",
      target: "empty_state"
    )
  }

  after_update_commit -> {
    broadcast_replace_to(
      "channel_#{channel_id}",
      partial: "messages/message",
      locals: { message: self, current_user: user }
    )
  }

  after_destroy_commit -> {
    broadcast_remove_to "channel_#{channel_id}"
  }

  validates :body, presence: true
end
