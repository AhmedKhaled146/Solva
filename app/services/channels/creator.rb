module Channels
  class Creator < BaseService
    attr_reader :channel, :errors

    def initialize(workspace, channel_params, current_user)
      @workspace = workspace
      @channel_params = channel_params
      @current_user = current_user
      @channel = nil
      @errors = []
    end

    def call
      @channel = @workspace.channels.new(@channel_params)

      return false unless authorize_private_channel_creation

      @channel.save
    end

    private

    def authorize_private_channel_creation
      return true unless @channel.privacy_private?

      is_authorized = @workspace.role_owner?(@current_user) ||
                      @workspace.role_admin?(@current_user)

      unless is_authorized
        @errors << "Only admins and owners can create private channels."
      end

      is_authorized
    end
  end
end