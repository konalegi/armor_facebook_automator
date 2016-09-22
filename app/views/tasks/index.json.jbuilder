json.total @total

json.rows do
  json.array!(@tasks) do |task|
    json.id task.id
    json.login  task.login
    json.password  task.password
    json.employer  task.employer
    json.location  task.location
    json.story  task.story
    json.start_date  task.start_date
    json.aasm_state task.aasm_state

    if task.may_start?
      start_button =  link_to "Start", '#', :onclick => "start_task(#{task.id})"
      # start_button = link_to(start_task_path(task), method: :put,
      #                                             title: "Начать", class: "btn btn-default btn-xs"){
      #   '<span class="glyphicon glyphicon-play-circle" aria-hidden="true"></span>'.html_safe }
    end

    json.actionlinks [start_button].join
  end
end