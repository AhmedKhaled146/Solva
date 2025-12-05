module MessageAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :set_message, only: [:show, :edit, :update, :destroy]
  end

  private

  def set_message
    @message = find_resource(
      @channel.messages,
      params[:message_id] || params[:id],
      error_message: "Message not found.",
      redirect_path: workspace_channel_path(@workspace, @channel)
    )
  end

  def authorize_message_owner!
    authorize_resource!(
      @message.user == current_user,
      message: "You are not authorized to modify this message.",
      redirect_to: workspace_channel_path(@workspace, @channel)
    )
  end
end