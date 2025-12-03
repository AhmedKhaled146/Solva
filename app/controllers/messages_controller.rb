class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workspace
  before_action :set_channel
  before_action :set_message, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_message_owner!, only: [ :edit, :update, :destroy ]

  def show
  end
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

  def edit
  end

  def update
    if @message.update(message_params)
      respond_to do |format|
        format.turbo_stream do
          streams = []
          streams << turbo_stream.replace(
            helpers.dom_id(@message),
            partial: "messages/message",
            locals: { message: @message, workspace: @workspace, channel: @channel }
          )
          if request.headers["Turbo-Frame"] == "message_thread"
             streams << turbo_stream.update(
              "message_thread",
              template: "messages/show",
              locals: { message: @message, workspace: @workspace, channel: @channel }
            )
          end
          render turbo_stream: streams
        end
        format.html do
          redirect_to workspace_channel_path(@workspace, @channel),
                      notice: "Message updated successfully."
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @message.destroy
    redirect_to workspace_channel_path(@workspace, @channel),
                notice: "Message deleted successfully."
  end

  private
  def set_workspace
    @workspace = Workspace.find(params[:workspace_id])
  end

  def set_channel
    @channel = @workspace.channels.find(params[:channel_id])
  end

  def set_message
    @message = @channel.messages.find(params[:id])
  end

  def authorize_message_owner!
    return if @message.user == current_user

    redirect_to workspace_channel_path(@workspace, @channel),
                alert: "You are not authorized to modify this message."
  end
  def message_params
    params.require(:message).permit(:body)
  end
end
