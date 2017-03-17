class MessagesController < ApplicationController
  def index
    @messages = Message.all
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    if @message.save
      flash[:success] = "Success"
     	ActionCable.server.broadcast("chat", @message.body) 
    else
      flash[:error] = @message.errors.full_messages.to_sentence
      redirect_to root_path
    end
  end
  
  private 
    def message_params
      params.require(:message).permit(:body)
    end
end
