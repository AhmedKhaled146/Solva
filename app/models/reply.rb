class Reply < ApplicationRecord
  belongs_to :message
  belongs_to :user

  validates :body, presence: true
  
  # Broadcast new replies to the message stream
  after_create_commit -> {
    broadcast_append_to message, 
                        target: "message_#{message.id}_replies", 
                        partial: "replies/reply", 
                        locals: { reply: self }
  }
end
