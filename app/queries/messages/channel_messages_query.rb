module Messages
  class ChannelMessagesQuery < BaseQuery
    def initialize(channel)
      super(channel.messages)
    end

    def call
      relation
        .includes(:user, :replies)
        .order(created_at: :asc)
    end
  end
end