class RepliesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workspace
  before_action :set_channel
  before_action :set_message
  before_action :set_reply, only: [ :show ]

  def index
    @replies = @message.replies.order(created_at: :desc)
  end

  def show
  end

  def create
    @reply = @message.replies.new(reply_params)
    @reply.user = current_user

    respond_to do |format|
      if @reply.save
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "reply_form_#{@message.id}",
            partial: "replies/form",
            locals: { message: @message, reply: Reply.new, workspace: @workspace, channel: @channel }
          )
        end
        format.html { redirect_to workspace_channel_path(@workspace, @channel) }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "reply_form_#{@message.id}",
            partial: "replies/form",
            locals: { message: @message, reply: @reply }
          )
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

  def set_message
    @message = @channel.messages.find(params[:message_id])
  end

  def set_reply
    @reply = @message.replies.find(params[:id])
  end

  def reply_params
    params.require(:reply).permit(:body)
  end
end
