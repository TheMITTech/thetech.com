MessageBus.start()

MessageBus.callbackInterval = 500

MessageBus.subscribe '/updates', (data) ->
  console.log("Model: " + data.model + ", ID: " + data.id)
