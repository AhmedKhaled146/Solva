class WorkspacesController < ApplicationController
  include WorkspaceAuthorization

  before_action :authenticate_user!
  before_action :set_workspace, only: [:show, :edit, :update, :destroy, :invite, :send_invite]
  before_action :authorize_workspace_owner!, only: [:update, :destroy, :invite, :send_invite]


  def index
    @workspaces = current_user.workspaces.includes(:memberships)
  end

  def show
    @channels = user_visible_channels
    @memberships = @workspace.memberships.includes(:user).limit(10)
  end

  def new
    @workspace = Workspace.new
  end

  def create
    service = Workspaces::Creator.new(workspace_params, current_user)

    if service.call
      respond_with_success(
        service.workspace,
        notice: "#{service.workspace.name} Workspace created successfully"
      )
    else
      @workspace = service.workspace
      render_form_errors(:new, @workspace)
    end
  end

  def edit
  end

  def update
    if @workspace.update(workspace_params)
      respond_with_success(
        @workspace,
        notice: "#{@workspace.name} Workspace updated successfully"
      )
    else
      render_form_errors(:edit, @workspace)
    end
  end

  def destroy
    workspace_name = @workspace.name
    @workspace.destroy
    respond_with_success(
      workspaces_path,
      notice: "#{workspace_name} was successfully destroyed."
    )
  end

  # Invite actions
  def join_with_link
  end

  def perform_join
    service = Workspaces::InviteLinkJoiner.new(params[:invite_link], current_user)

    if service.call
      respond_with_success(
        workspace_path(service.workspace),
        notice: "You joined #{service.workspace.name} successfully."
      )
    else
      respond_with_error(
        join_with_link_workspaces_path,
        alert: service.errors.first
      )
    end
  end

  def invite
  end

  def send_invite
    service = Workspaces::EmailInviter.new(params[:email], @workspace)

    if service.call
      respond_with_success(
        @workspace,
        notice: "Invitation sent to #{params[:email]}"
      )
    else
      respond_with_error(
        invite_workspace_path(@workspace),
        alert: service.errors.first
      )
    end
  end

  def join_from_email
    token = params[:token]
    @workspace = Workspace.find_by(invited_token: token)

    unless @workspace
      return respond_with_error(root_path, alert: "Invalid invite link")
    end

    unless user_signed_in?
      redirect_to new_user_session_path(return_to: join_from_email_workspace_path(token))
    end
  end

  def confirm_join_from_email
    token = params[:token]
    @workspace = Workspace.find_by(invited_token: token)

    unless @workspace
      return respond_with_error(root_path, alert: "Invalid invite link")
    end

    membership = @workspace.memberships.find_or_initialize_by(user: current_user)

    if membership.persisted?
      respond_with_success(@workspace, notice: "You already joined this workspace.")
    else
      membership.role = :member
      membership.save!
      respond_with_success(@workspace, notice: "Welcome to #{@workspace.name}!")
    end
  end

  private

  def workspace_params
    params.require(:workspace).permit(:name)
  end

  def user_visible_channels
    if current_user_is_owner? || current_user_is_admin?
      @workspace.channels
    else
      @workspace.channels.where(privacy: "public")
    end
  end
end