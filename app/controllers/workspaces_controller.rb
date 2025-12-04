class WorkspacesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workspace, only: [ :show, :update, :destroy, :edit ]
  before_action :authorize_workspace_owner, only: [ :update, :destroy ]

  def index
    @workspaces = current_user.workspaces.includes(:memberships)
  end

  def show
    is_owner = @workspace.role_owner?(current_user)
    is_admin = @workspace.role_admin?(current_user)

    @channels =
      if is_owner || is_admin
        @workspace.channels
      else
        @workspace.channels.where(privacy: "public")
      end
  end

  def new
    @workspace = Workspace.new
  end

  def create
    @workspace = Workspace.new(workspace_params)

    ActiveRecord::Base.transaction do
      respond_to do |format|
        if @workspace.save
          Membership.create!(
            user: current_user,
            workspace: @workspace,
            role: :owner
          )

          format.html do
            redirect_to @workspace,
                        notice: "#{@workspace.name} Workspace created successfully"
          end
        else
          format.html do
            render :new,
                   status: :unprocessable_entity
          end
        end
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @workspace.update(workspace_params)
        format.html do
          redirect_to @workspace,
                      notice: "#{@workspace.name} Workspace updated successfully"
        end
      else
        format.html do
          render :edit,
                 status: :unprocessable_entity
        end
      end
    end
  end

  def join_with_link
  end

  def perform_join
    raw_input = params[:invite_link].to_s.strip

    token =
      if raw_input.include?("http")
        # http://localhost:3000/workspaces/INVITED_TOKEN
        uri = URI.parse(raw_input) rescue nil
        if uri && uri.path
          uri.path.split("/").last
        end
      else
        raw_input
      end

    workspace = Workspace.find_by(invited_token: token)

    if workspace.nil?
      redirect_to join_with_link_workspaces_path,
                  alert: "Invalid or expired invite link."
      return
    end

    membership = workspace.memberships.find_or_initialize_by(user: current_user)

    if membership.persisted?
      redirect_to workspace_path(workspace),
                  notice: "You already joined this workspace."
    else
      membership.role = :member

      if membership.save
        redirect_to workspace_path(workspace),
                    notice: "You joined #{workspace.name} successfully."
      else
        redirect_to join_with_link_workspaces_path,
                    alert: "Could not join this workspace."
      end
    end
  end

  def destroy
    @workspace.destroy
    respond_to do |format|
      format.html { redirect_to workspaces_path, notice: "#{@workspace.name} was successfully destroyed." }
    end
  end

  def invite
    @workspace = Workspace.find(params[:id])
    authorize_workspace_owner
  end

  def send_invite
    @workspace = Workspace.find(params[:id])
    authorize_workspace_owner

    email = params[:email].to_s.strip

    if email.blank?
      redirect_to join_from_email(@workspace), alert: "Email can't be blank"
      return
    end

    WorkspaceInviteMailer.invite_email(email, @workspace).deliver_now

    redirect_to @workspace, notice: "Invitation sent to #{email}"
  end

  def join_from_email
    token = params[:token]
    @workspace = Workspace.find_by(invited_token: token)

    if @workspace.nil?
      redirect_to root_path, alert: "Invalid invite link"
      return
    end

    unless user_signed_in?
      redirect_to new_user_session_path(return_to: join_from_email_workspace_path(token))
      return
    end
  end

  def confirm_join_from_email
    token = params[:token]
    @workspace = Workspace.find_by(invited_token: token)

    if @workspace.nil?
      redirect_to root_path, alert: "Invalid invite link"
      return
    end

    membership = @workspace.memberships.find_or_initialize_by(user: current_user)

    if membership.persisted?
      redirect_to @workspace, notice: "You already joined this workspace."
    else
      membership.role = :member
      membership.save
      redirect_to @workspace, notice: "Welcome to #{@workspace.name}!"
    end
  end


  private
    def set_workspace
      @workspace = Workspace.find(params[:id])
    end

    def workspace_params
      params.require(:workspace).permit(:name)
    end

    def create_invited_token
      SecureRandom.hex(16)
    end

    def authorize_workspace_owner
      unless current_user == @workspace.owner
        redirect_to workspace_path(@workspace),
                    alert: "You are not authorized to perform this action."
      end
    end
end
