class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)

    if @message.sender == @message.message_thread.seller
      @message.receiver = @message.message_thread.buyer
    else
      @message.receiver = @message.message_thread.seller
    end

    respond_to do |format|
      if @message.save
        MessageBroadcastController.publish('/messages', @message.detailed_attributes)
        format.json { render json: @message.attributes, status: :created }
      else
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:sender_id, :receiver_id, :message, :message_thread_id)
    end
end
