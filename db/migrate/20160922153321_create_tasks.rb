class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.string :login
      t.string :password
      t.string :employer
      t.string :location
      t.string :story
      t.date :start_date
      t.string :aasm_state

      t.timestamps
    end
  end
end
