class MembershipsController < ApplicationController
  include WorkspaceAuthorization
  include MembershipAuthorization

  before_action :authenticate_user!
  before_action :set_workspace
  before_action :set_membership, only: [ :update, :destroy ]
  before_action :authorize_membership_update!, only: [ :index, :update ]
  before_action :authorize_membership_destroy!, only: [ :destroy ]

  def index
    @memberships = @workspace.memberships.includes(:user)
  end

  def update
    service = Memberships::RoleUpdater.new(@membership, membership_params, current_user)

    if service.call
      respond_with_success(
        workspace_memberships_path(@workspace),
        notice: "Role updated successfully."
      )
    else
      respond_with_error(
        workspace_memberships_path(@workspace),
        alert: service.errors.first
      )
    end
  end

  def destroy
    service = Memberships::Remover.new(@membership, current_user)

    if service.call
      respond_with_success(
        workspace_memberships_path(@workspace),
        notice: "User removed from workspace."
      )
    else
      respond_with_error(
        workspace_memberships_path(@workspace),
        alert: service.errors.first
      )
    end
  end

  private

  def membership_params
    params.require(:membership).permit(:role)
  end
end