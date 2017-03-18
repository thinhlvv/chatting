# Ruby Lab 5: Understanding the Journey from HTTP to WebSocket - CoderSchool

## Required features

### Milestone 1: a project from scratch that displays chat messages.

- [x] Set up a new rails project named `lab5` using PostgreSQL. Git init, git commit and git push to your pair's repo.
- [x] Generate a `Message` resource with a `body` string column. Add validation. Implement `/messages` to display all messages (newest first).
- [x] Set up root path to `HomeController#index`. Inside it, redirect visitors to `messages_path`.
- [x] On `/messages`, refactor the view to use `render @messages` and implement `_message.html.erb` partial. Your generated HTML should look like this:

  ```erb
  <div class="messages">
    <div id="message_1" class="message">How are you?</div>
    <div id="message_2" class="message">I'm fine, thanks. You?</div>
    <div id="message_3" class="message">Great! I love coding.</div>
  </div>
  ```

- [x] Create a few new messages from `rails console` and check your view.

### Milestone 2: support submitting new chat messages.

- [x] Implement `flash_messages` helper in ApplicationHelper and display `<%= flash_messages %>` before `<%= yield %>` in application layout.
- [x] Implement a new message form (`form_for Message.new`) before `<div class="messages">...</div>`. Make sure `Messages#create` work as expected.
- [x] Run `rails s -b 0.0.0.0` and get your IP address via `ifconfig | grep broadcast`. Now ask your supervisor to visit your IP, port 3000 (e.g. `192.179.X.X:3000`) and test chatting.

### Milestone 3: set up client-server WebSocket communication.

- [x] Generate a `messages`channel. Inside MessagesChannel, add `stream_from "chat"` under `def subscribed`.
- [x] Add the following code for the server to receive data from clients:

  ```
  # note it's 'receive', not 'received'
  def receive(data)
    Rails.logger.info("MessagesChannel got: #{data.inspect}")
  end
  ```

- [x] Go to `app/assets/javascripts/channels/message.coffee` and add `console.log("connected")` under the `connected` function. Reload the browser, open Inspector Console and make sure you see the message.
- [x] Still in Inspector Console, send a message to the server by typing `App.messages.send({message: "hello"})`. Check Rails server log, make sure you see this:

  ```
  # rails server log
  MessagesChannel#receive({"message"=>"hello"})                                                        │
  MessagesChannel got: {"message"=>"hello"}
  ```

  ** You just got Server to receive messages from Client! ** Now let's make Server broadcast the same messages to all other clients.

- [x] Update `MessagesChannel#receive` to broadcast the same data to all clients under the stream `"chat"` (HINT: `ActionCable.server.broadcast`)
- [x] Inside `received: (data) ->` function, add CoffeeScript to print data to console: `console.log("client receives ", data)`

![](http://g.recordit.co/x63FZAwU4G.gif)

- [x] Insert `data.message` as HTML at the beginning of your `<div class="messages">...</div>` text (HINT: use jQuery's `.prepend`). Test sending `App.messages.send({message: "hello"})`and make sure another browser receives new message content.

Please show your TAs/Teacher your work.

### Milestone 4: broadcast new messages to all clients in `MessagesController#create`

- [x] In `MessagesController#create`, after a message is saved, broadcast `{message: @message.body}` to the `chat` stream.

Verify:

- User A and User B have their browsers open.
- User A submits a new chat message in Browser A.
- Browser A reloads the page (regular form submit) and displays the latest messages.
- Browser B receives updates via Web Socket and also displays the latest messages.
- If A sends more messages, B continues to render them but they look ugly.

- [x] Let's make the message pretty. Create a `render_message(message)` private method in `MessagesController`. Then broadcast `data: render_message(@message)` instead.

  ```ruby
  def render_message(message)
    ApplicationController.render(partial: 'messages/message', locals: {message: message})
  end
  ```

Now you have a working real-time chat app. Please show TAs/Teacher your work.

### Milestone 5: skip MessagesController; submit directly to MessagesChannel instead

In Milestone 4, we only use MessagesChannel to broadcast data to client. Client still submits new message content via HTTP.

If Client submits new message content ONLY via Web Socket, we can skip HTTP & MessagesController.

Let's create a new message form which submits via Javascript via a Web Socket:

```html
<form id="js-socket">
  <label>
    <input type="text" placeholder="Type something..." />
    WebSocket Style
  </label>
</form>
```

Add HTTP style label to the old form. You'll have something like this:

![](https://dl.dropboxusercontent.com/spa/vkwvskbavc27sn4/tbetw04q.png)

- [ ] In `app/assets/javascripts/messages.coffee` add a method to catch the form submit event:

  ```coffee
  $(document).on "turbolinks:load", ->
    $("form#js-socket").submit (event) ->
      console.log("stopping submitting via HTTP")
      event.preventDefault()

      # use jQuery to find the text input:
      $input = $(this).find('input:text')
      data = {message: {body: $input.val()}}
      console.log("sending over socket: ", data)
      App.messages.send(data)
      # clear text field
      $input.val('')
  ```

NOTE: in Lecture 5, we used observe the `keyup` event and submit data if an Enter is found. In this lab, we just used a different way: intercepting HTML form.

- [ ] Now make MessagesChannel handle the saved data:

  ```ruby
  def receive(data)
    Rails.logger.info("MessagesChannel got: #{data.inspect}")

    # note: data[:message] will not work. use string as hash keys here
    @message = Message.create(data['message'])
    if @message.persisted?
      ActionCable.server.broadcast("chat", message: render_message(@message))
    end
  end

  private

  def render_message(message)
    # ... same content as the method in MessagesController
  end
  ```

Verify:

- User A and User B have their browsers open.
- User A enter a new chat message and press Enter (text is submitted by Javascript via Web Socket)
- Each browser receives updates via Web Socket and also displays the latest messages.

### Milestone 6: refactor channel code

- [ ] Server: in MessagesController, implement a `def create(data)` method that create a message from `data['message']` and broadcast the message rendering to the `chat` stream.
- [ ] Client: in `app/assets/javascripts/channels/messages.coffee`, implement a `create: (body)` method:

  ```coffee
  App.messages = App.cable.subscriptions.create "MessagesChannel",
    # ...

    create: (data) ->
      @perform("create", message: data)
  ```

- [ ] Browser Console: try typing `App.messages.create({body: "this is a message"})`. Verify that this goes to MessagesChannel#create and that you see the new message in the browser.

![](http://g.recordit.co/tU0C8eSklm.gif)

- [ ] Update `app/assets/javascripts/messages.coffee` with clearer code:


  ```coffee
  $(document).on "turbolinks:load", ->
    $("form#js-socket").submit (event) ->
      console.log("stopping submitting via HTTP")
      event.preventDefault()

      # cache element to a variable $input
      $input = $(this).find('input:text')

      data = {body: $input.val()}
      console.log("sending over socket: ", data)
      App.messages.create(data)

      $input.val('')
  ```

  Notice the difference: we don't go through the `MessagesChannel#receive`, but directly: `App.messages.create` --> `MessagesChannel#create`

## Optional features

### Bonus Milestone 7: implement deleting a message

- [ ] Inside 'message' partial, add a link to delete a message
- [ ] Create a `delete: (messageId) ->` method inside `App.messages = App.cable.subscriptions.create "MessagesChannel"` which calls `this.perform("delete", id: messageId)`
- [ ] Create a `def delete(data)` in `MessagesChannel` which handles removing the affected message and broadcast information to update the clients.

### Bonus Milestone 8: implement multiple chat rooms.

If you got here, you are good enough to write your own checkboxes :)
