# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(".messages").prepend("<h1>Prepended text</h1>");

$(document).on "turbolinks:load", ->
  $("form#js-socket").submit (event) ->
    console.log("stopping submitting via HTTP")
    event.preventDefault()

    # use jQuery to find the text input:
    $input = $(this).find('input:text')
    data = {message: {body: $input.val()}}
    console.log("sending over socket: ", data)
    App.messages.create({body: data})
    # clear text field
    $input.val('')
