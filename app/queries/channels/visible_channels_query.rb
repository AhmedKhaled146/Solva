module Channels
  class VisibleChannelsQuery < BaseQuery
    def initialize(workspace, user)
      @workspace = workspace
      @user = user
      super(workspace.channels)
    end

    def call
      return relation if user_is_admin_or_owner?

      relation.where(privacy: "public")
    end

    private

    def user_is_admin_or_owner?
      @workspace.role_owner?(@user) || @workspace.role_admin?(@user)
    end
  end
end