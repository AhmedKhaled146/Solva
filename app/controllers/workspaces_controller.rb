class WorkspacesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workspace, only: [ :show, :update, :destroy, :edit ]
  before_action :authorize_workspace_owner, only: [ :update, :destroy ]

  def index
    @workspaces = current_user.workspaces.includes(:memberships)
  end

  def show
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


  def destroy
    @workspace.destroy
    respond_to do |format|
      format.html { redirect_to workspaces_path, notice: "#{@workspace.name} was successfully destroyed." }
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
