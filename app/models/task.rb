class Task < ApplicationRecord
  include AASM

  aasm do
    state :limb, initial: true
    state :completed
    state :failed
    state :started

    event :start, after_commit: :create_asynk_job do
      transitions from: [:completed, :limb, :failed], to: :started
    end

    event :complete do
      transitions from: :started, to: :completed
    end

    event :fail do
      transitions from: :started, to: :failed
    end
  end

  def self.asynk_task_completed(task_id, with_success, error_message = '')
    if with_success
      Task.find_by_id(task_id).complete!
    else
      Task.find_by_id(task_id).fail!
    end
    ActionCable.server.broadcast "tasks_channel", {}
  end

  private
    def create_asynk_job
      FacebookService.delay(retry: false).perform(id, {
        login: login,
        password: password,
        employer: employer,
        location: location,
        story: story,
        start_date: start_date
      })

      ActionCable.server.broadcast "tasks_channel", {}
    end

end
