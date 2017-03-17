class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    #Rails.logger.info("MessagesChannel got: #{data.inspect}")
    ActionCable.server.broadcast('chat', data)
  end
end
