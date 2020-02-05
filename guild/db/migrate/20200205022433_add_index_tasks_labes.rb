class AddIndexTasksLabes < ActiveRecord::Migration[5.1]
  def change
    add_index :tasks, :label
  end
end
