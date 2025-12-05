class MessagesController < ApplicationController
  include WorkspaceAuthorization
  include ChannelAuthorization
  include MessageAuthorization

  before_action :authenticate_user!
  before_action :set_workspace
  before_action :authorize_workspace_member!
  before_action :set_channel
  before_action :set_message, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_message_owner!, only: [ :edit, :update, :destroy ]

  def show
  end

  def create
    @message = @channel.messages.new(message_params)
    @message.user = current_user

    if @message.save
      respond_with_success(
        workspace_channel_path(@workspace, @channel),
        notice: nil
      )
    else
      respond_with_error(
        workspace_channel_path(@workspace, @channel),
        alert: "Message could not be sent."
      )
    end
  end

  def edit
  end

  def update
    if @message.update(message_params)
      respond_to do |format|
        format.turbo_stream do
          render_turbo_stream_update
        end
        format.html do
          respond_with_success(
            workspace_channel_path(@workspace, @channel),
            notice: "Message updated successfully."
          )
        end
      end
    else
      render_form_errors(:edit, @message)
    end
  end

  def destroy
    @message.destroy
    respond_with_success(
      workspace_channel_path(@workspace, @channel),
      notice: "Message deleted successfully."
    )
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end

  def render_turbo_stream_update
    streams = []
    streams << turbo_stream.replace(
      helpers.dom_id(@message),
      partial: "messages/message",
      locals: { message: @message, workspace: @workspace, channel: @channel }
    )

    if request.headers["Turbo-Frame"] == "message_thread"
      streams << turbo_stream.replace(
        "message_#{@message.id}",
        partial: "messages/message",
        locals: { message: @message, workspace: @workspace, channel: @channel }
      )
      streams << turbo_stream.update("edit_message_form", "")
    end

    render turbo_stream: streams
  end
end