module ChannelAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :set_channel, only: [ :show, :edit, :update, :destroy ]
  end

  private

  def set_channel
    unless @workspace
      respond_to do |format|
        format.html do
          redirect_to workspaces_path, alert: "Workspace not found."
        end
        format.json { render json: { error: "Workspace not found" }, status: :not_found }
      end
      return
    end

    channel_id = params[:channel_id] || params[:id]
    @channel = find_resource(
      @workspace.channels,
      channel_id,
      error_message: "Channel not found.",
      redirect_path: workspace_path(@workspace)
    )
  end

  def authorize_channel_access!
    return if current_user_is_owner?
    return if current_user_is_admin?
    return if @channel.privacy_public?

    authorize_resource!(
      false,
      message: "You are not authorized to access this channel.",
      redirect_to: workspace_channels_path(@workspace)
    )
  end

  def user_visible_channels
    if current_user_is_owner? || current_user_is_admin?
      @workspace.channels
    else
      @workspace.channels.where(privacy: "public")
    end
  end
end