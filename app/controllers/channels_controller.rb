class ChannelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workspace
  before_action :set_channel, only: [ :show, :edit, :update, :destroy ]

  def index
    @channels = @workspace.channels
  end

  def show
  end

  def new
    @channel = @workspace.channels.new
  end

  def create
    @channel = @workspace.channels.new(channel_params)

    wants_private = @channel.privacy_private?
    is_owner      = @workspace.role_owner?(current_user)
    is_admin      = @workspace.role_admin?(current_user)

    if wants_private && !is_owner && !is_admin
      redirect_to workspace_path(@workspace),
                  alert: "Only admins and owners can create private channels."
      return
    end

    if @channel.save
      redirect_to workspace_path(@workspace),
                  notice: "Channel #{@channel.name} created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @channel.update(channel_params)
        format.html do
          redirect_to workspace_path(@workspace),
                      notice: "Channel #{@channel.name} updated successfully."
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
    @channel.destroy
    respond_to do |format|
      format.html do
        redirect_to workspace_path(@workspace),
                    notice: "#{@channel.name} Channel deleted successfully."
      end
    end
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

  def set_channel
    @channel = @workspace.channels.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html do
        redirect_to workspace_path(@workspace),
                    alert: "Channel not found."
      end
    end
  end

  def channel_params
    params.require(:channel).permit(:name, :description, :privacy)
  end
end
