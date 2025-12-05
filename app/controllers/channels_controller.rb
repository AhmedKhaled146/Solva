class ChannelsController < ApplicationController
  include WorkspaceAuthorization
  include ChannelAuthorization

  before_action :authenticate_user!
  before_action :set_workspace
  before_action :authorize_workspace_member!
  before_action :set_channel, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_channel_owner!, only: [ :edit, :update, :destroy ]
  before_action :authorize_channel_access!, only: [ :show, :edit, :update, :destroy ]


  def index
    @channels = Channels::VisibleChannelsQuery.new(@workspace, current_user).call
  end

  def show
    @messages = Messages::ChannelMessagesQuery.new(@channel).call
  end

  def new
    @channel = @workspace.channels.new
  end

  def create
    service = Channels::Creator.new(@workspace, channel_params, current_user)

    if service.call
      respond_with_success(
        workspace_path(@workspace),
        notice: "Channel #{service.channel.name} created successfully."
      )
    else
      @channel = service.channel
      if service.errors.any?
        respond_with_error(workspace_path(@workspace), alert: service.errors.first)
      else
        render_form_errors(:new, @channel)
      end
    end
  end

  def edit
  end

  def update
    if @channel.update(channel_params)
      respond_with_success(
        workspace_path(@workspace),
        notice: "Channel #{@channel.name} updated successfully."
      )
    else
      render_form_errors(:edit, @channel)
    end
  end

  def destroy
    channel_name = @channel.name
    @channel.destroy
    respond_with_success(
      workspace_path(@workspace),
      notice: "#{channel_name} Channel deleted successfully."
    )
  end

  private

  def channel_params
    params.require(:channel).permit(:name, :description, :privacy)
  end

  def authorize_channel_owner!
    unless current_user_is_owner? || current_user_is_admin?
      redirect_to workspace_path(@workspace),
                  alert: "Only workspace admins and owners can modify channels."
    end
  end
end