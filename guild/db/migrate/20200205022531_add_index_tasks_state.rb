class AddIndexTasksState < ActiveRecord::Migration[5.1]
  def change
    add_index :tasks, :state
  end
end
