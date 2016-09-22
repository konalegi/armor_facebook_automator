App.tasks = App.cable.subscriptions.create 'TasksChannel',
  connected: ->
    console.log 'i am connected'

  disconnected: ->
    console.log 'i am disconnected'

  received: (data) ->
    $table.bootstrapTable('refresh');