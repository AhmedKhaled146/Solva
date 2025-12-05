module MembershipAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :set_membership, only: [:update, :destroy]
  end

  private

  def set_membership
    @membership = find_resource(
      @workspace.memberships,
      params[:id],
      error_message: "Membership not found.",
      redirect_path: workspace_memberships_path(@workspace)
    )
  end

  def authorize_membership_update!
    authorize_admin!(@workspace)
  end

  def authorize_membership_destroy!
    authorize_resource!(
      @workspace.role_owner?(current_user),
      message: "Only the workspace owner can remove members.",
      redirect_to: workspace_memberships_path(@workspace)
    )
  end
end