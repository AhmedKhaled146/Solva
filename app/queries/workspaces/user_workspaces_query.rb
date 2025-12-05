module Workspaces
  class UserWorkspacesQuery < BaseQuery
    def initialize(user)
      super(user.workspaces)
    end

    def call
      relation
        .includes(:memberships, :channels)
        .order(created_at: :desc)
    end
  end
end