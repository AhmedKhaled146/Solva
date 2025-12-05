module WorkspaceAuthorization
  extend ActiveSupport::Concern

  private

  def set_workspace
    workspace_id = params[:workspace_id] || params[:id]
    @workspace = find_resource(
      Workspace,
      workspace_id,
      error_message: "Workspace not found.",
      redirect_path: workspaces_path
    )
  end

  def authorize_workspace_member!
    unless current_user_is_workspace_member?
      respond_to do |format|
        format.html do
          redirect_to workspaces_path,
                      alert: "You must be a member of this workspace to access it."
        end
        format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      end
    end
  end

  def authorize_workspace_owner!
    authorize_owner!(@workspace)
  end

  def authorize_workspace_admin!
    authorize_admin!(@workspace)
  end

  def current_user_workspace_role
    @workspace.role_for(current_user)
  end

  def current_user_is_owner?
    @workspace.role_owner?(current_user)
  end

  def current_user_is_admin?
    @workspace.role_admin?(current_user)
  end

  def current_user_is_member?
    @workspace.role_member?(current_user)
  end

  def current_user_is_workspace_member?
    @workspace.memberships.exists?(user_id: current_user.id)
  end
end
