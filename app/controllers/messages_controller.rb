class MessagesController < ApplicationController
  def index
    @messages = Message.all.reverse
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    if @message.save
      flash[:success] = "Success"
     	ActionCable.server.broadcast("chat", @message.body) 
      render_message(@message)
    else
      flash[:error] = @message.errors.full_messages.to_sentence
      redirect_to root_path
    end
  end
  
  private 
    def message_params
      params.require(:message).permit(:body)
    end
    
    def render_message(message)
    ApplicationController.render(partial: 'messages/message', locals: {message: message})
  end

end
