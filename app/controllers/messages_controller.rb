class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workspace
  before_action :set_channel

  def create
    @message = @channel.messages.new(message_params)
    @message.user = current_user

    respond_to do |format|
      if @message.save
        ChannelMessagesChannel.broadcast_to(
          @channel,
          render_to_string(
            partial: "messages/message",
            locals: { message: @message }
          )
        )

        format.html do
          redirect_to workspace_channel_path(@workspace, @channel)
        end
      else
        format.html do
          redirect_to workspace_channel_path(@workspace, @channel),
                      alert: "Message could not be sent."
        end
      end
    end
  end

  private
  def set_workspace
    @workspace = Workspace.find(params[:workspace_id])
  end

  def set_channel
    @channel = @workspace.channels.find(params[:channel_id])
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
