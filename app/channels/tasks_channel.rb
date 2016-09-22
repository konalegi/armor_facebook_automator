class TasksChannel < ApplicationCable::Channel
  def subscribed
    stream_from "tasks_channel"
  end

  def unsubscribed
  end
end
