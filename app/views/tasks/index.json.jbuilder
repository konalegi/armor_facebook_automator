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
      start_button =  content_tag(:span, "Start", :onclick => "start_task(#{task.id})", class: 'btn btn-primary active')
    else
      start_button =  content_tag(:span, "Start", class: 'btn btn-primary disabled')
    end

    json.actionlinks [start_button].join
  end
end