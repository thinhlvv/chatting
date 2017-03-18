class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    #Rails.logger.info("MessagesChannel got: #{data.inspect}")
    # ActionCable.server.broadcast('chat', data)
    # note: data[:message] will not work. use string as hash keys here
  end
  
  def render_message(message)
    ApplicationController.render(partial: 'messages/message', locals: {message: message})
  end

  def create(data)
    @message = Message.create(data['message'])
    if @message.persisted?
      ActionCable.server.broadcast("chat", message: render_message(@message.body('message')))
    end 
  end

end
