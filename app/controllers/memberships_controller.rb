class MembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workspace
  before_action :set_membership, only: [ :update, :destroy ]
  before_action :authorize_admin!, only: [ :index, :update ]
  before_action :authorize_owner_for_destroy!, only: [ :destroy ]

  def index
    @memberships = @workspace.memberships.includes(:user)
  end

  def update
    if @membership.update(membership_params)
      redirect_to workspace_memberships_path(@workspace),
                  notice: "Role updated successfully."
    else
      redirect_to workspace_memberships_path(@workspace),
                  alert: @membership.errors.full_messages.to_sentence
    end
  end

  def destroy
    if @membership.owner?
      redirect_to workspace_memberships_path(@workspace),
                  alert: "Owner cannot be removed from the workspace."
      return
    end

    @membership.destroy
    redirect_to workspace_memberships_path(@workspace),
                notice: "User removed from workspace."
  end

  private

  def set_workspace
    @workspace = Workspace.find(params[:workspace_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html do
        redirect_to workspaces_path,
                    alert: "Workspace not found."
      end
    end
  end

  def set_membership
    @membership = @workspace.memberships.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html do
        redirect_to workspace_memberships_path(@workspace),
                    alert: "Membership not found."
      end
    end
  end

  def membership_params
    params.require(:membership).permit(:role)
  end

  def authorize_admin!
    unless @workspace.role_owner?(current_user) || @workspace.role_admin?(current_user)
      redirect_to workspace_path(@workspace),
                  alert: "You are not authorized to manage workspace members."
    end
  end

  def authorize_owner_for_destroy!
    unless @workspace.role_owner?(current_user)
      redirect_to workspace_memberships_path(@workspace),
                  alert: "Only the workspace owner can remove members."
    end
  end
end
