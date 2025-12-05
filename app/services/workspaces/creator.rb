module Workspaces
  class Creator < BaseService
    attr_reader :workspace, :errors

    def initialize(workspace_params, owner)
      @workspace_params = workspace_params
      @owner = owner
      @workspace = nil
      @errors = []
    end

    def call
      ActiveRecord::Base.transaction do
        create_workspace
        create_owner_membership
        true
      end
    rescue ActiveRecord::RecordInvalid => e
      @errors << e.message
      false
    end

    private

    def create_workspace
      @workspace = Workspace.create!(@workspace_params)
    end

    def create_owner_membership
      Membership.create!(
        user: @owner,
        workspace: @workspace,
        role: :owner
      )
    end
  end
end