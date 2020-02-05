class LogicBoard
  LIMIT = 10
 # require 'task'
  require 'value_objects/state'
  require 'value_objects/priority'
  require 'value_objects/label'

  def self.index(user_id)
    {
      'state_list'    => get_state_list,
      'priority_list' => get_priority_list,
      'label_list'    => get_label_list,
    }.merge(get_task_all(user_id))
  end

  def self.get_task_all(user_id)
    {
      'task_list' => Task.where(user_id: user_id).order(created_at: "DESC")
    }
  end

  def self.get_task_by_id(user_id, id)
    {
      'task' => Task.find_by_id(id)
    }
  end

  def self.get_task_by_search_conditions(user_id, conditions)
    {
      'task_list' => Task.where(getConditionString(user_id, conditions)).order(created_at: "DESC")
    }
  end

  def self.get_state_list
    ValueObjects::State.get_list
  end

  def self.get_priority_list
    ValueObjects::Priority.get_list
  end

  def self.get_label_list
    ValueObjects::Label.get_list
  end

  def self.create(user_id, params)
    task = Task.new(
      user_id:     user_id,
      subject:     params['subject'],
      description: params['description'],
      state:       1,
      priority:    params['priority'],
      label:       params['label']
    )
    return false unless task.valid? && task.save
    return task.id
  end

  def self.update(user_id, params)
    task = Task.find_by_id(params['id'])
    return false if task.nil? || task.user_id != user_id
    task.subject     = params['subject']
    task.description = params['description']
    task.priority    = params['priority']
    task.label       = params['label']
    task.state       = params['state']
    return task.valid? && task.save
  end

  def self.delete(user_id, id)
    task = Task.find_by_id(id)
    return false if task.nil? || task.user_id != user_id
    return task.delete
  end

  def self.getConditionString(user_id, conditions)
      conditionsStr = "user_id = #{user_id}"
      conditions.each do |column, value|
        unless value.empty?
          conditionsStr = conditionsStr + " AND #{column} = #{value}"
        end
      end
      conditionsStr
    end
end
