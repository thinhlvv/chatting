App.messages = App.cable.subscriptions.create "MessagesChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    console.log("Fconnected")

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    console.log("client receives ", data)
    $(".messages").prepend('<div class="message">' + data.message + '</div>')

