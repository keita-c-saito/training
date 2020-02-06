require 'rails_helper'
require 'task'
require 'value_objects/state'
require 'value_objects/priority'
require 'value_objects/label'

describe LogicBoard , type: :model do

  let!(:task_a) { create(:task1) }
  let!(:task_b) {
    create(:task1,
      id: 2,
      subject: 'test subject 2nd',
      description: 'test description 2nd',
      state: 2,
      label: 2
    )
  }
  let!(:task_new) {
    create(:task1,
      id: 3,
      subject: 'new test subject',
      description: 'new test description',
      state: 3,
      label: 3,
      created_at: Time.current.tomorrow,
      updated_at: Time.current.tomorrow)
  }
  let(:user_id) {1}
  let(:ng_user_id) {999999}
  let(:expected) {
    {
      state:    ValueObjects::State.get_list,
      priority: ValueObjects::Priority.get_list,
      label:    ValueObjects::Label.get_list,
    }
  }

  describe '#index' do
    context 'Valid user' do
      it 'Task is found' do
        result = described_class.index(user_id)
        expect(result['task_list'].count).to eq 3
        expect(result['task_list'][0].id).to eq task_new.id
        result['task_list'].each do | task |
          expect(task).to be_an_instance_of(Task)
          expect(task.user_id).to eq user_id
        end
        expect(result['state_list']).to eq expected[:state]
        expect(result['priority_list']).to eq expected[:priority]
        expect(result['label_list']).to eq expected[:label]
      end
    end
    context 'Invalid user' do
      it 'Task is not found' do
        result = described_class.index(ng_user_id)
        expect(result['task_list'].empty?).to eq true
      end
    end
  end

  describe '#get_task_all' do
    context 'Valid user' do
      it 'Task is found' do
        result = described_class.get_task_all(user_id)
        expect(result['task_list'].count).to eq 3
        expect(result['task_list'][0].id).to eq task_new.id
        result['task_list'].each do | task |
          expect(task).to be_an_instance_of(Task)
          expect(task.user_id).to eq user_id
        end
      end
    end
    context 'Invalid user' do
      it 'Task is not found' do
        result = described_class.get_task_all(ng_user_id)
        expect(result['task_list'].empty?).to eq true
      end
    end
  end

  describe '#get_task_by_id' do
    context 'Valid user' do
      it 'Task is found' do
        result = described_class.get_task_by_id(user_id, task_a.id)
        expect(result['task']).to be_an_instance_of(Task)
        expect(result['task'].id).to eq task_a.id
        expect(result['task'].user_id).to eq task_a.user_id
      end
    end
    context 'Invalid user' do
      it 'Target task is not found' do
        ng_task_id = 999999
        result = described_class.get_task_by_id(user_id, ng_task_id)
        expect(result['task']).to be_nil
      end
    end
  end

  describe '#get_task_by_search_conditions' do
    context 'Valid user' do
      it 'Valid codition' do
        conditions = {'label' => task_a.label.to_s, 'state' => task_a.state.to_s}
        result = described_class.get_task_by_search_conditions(user_id, conditions)
        expect(result['task_list'].count).to eq 1
        expect(result['limit']).to eq described_class::LIMIT
        expect(result['total']).to eq 1
        expect(result['task_list'][0]).to eq task_a
      end
      it 'Invalid codition' do
        conditions = {'label' => task_a.label.to_s, 'state' => task_b.state.to_s}
        result = described_class.get_task_by_search_conditions(user_id, conditions)
        expect(result['task_list'].empty?).to eq true
        expect(result['limit']).to eq described_class::LIMIT
        expect(result['total']).to eq 0
      end
    end
    context 'Invalid user' do
      it 'Valid codition' do
        conditions = {'label' => task_a.label.to_s, 'state' => task_a.state.to_s}
        result = described_class.get_task_by_search_conditions(ng_user_id, conditions)
        expect(result['task_list'].empty?).to eq true
        expect(result['limit']).to eq described_class::LIMIT
        expect(result['total']).to eq 0
      end
      it 'Invalid codition' do
        conditions = {'label' => task_a.label.to_s, 'state' => task_b.state.to_s}
        result = described_class.get_task_by_search_conditions(ng_user_id, conditions)
        expect(result['task_list'].empty?).to eq true
        expect(result['limit']).to eq described_class::LIMIT
        expect(result['total']).to eq 0
      end
    end
  end

  describe '#get_state_list' do
    it 'Respond correctly' do
      expect(described_class.get_state_list).to eq expected[:state]
    end
  end

  describe '#get_priority_list' do
    it 'Respond correctly' do
      expect(described_class.get_priority_list).to eq expected[:priority]
    end
  end

  describe '#get_label_list' do
    it 'Respond correctly' do
      expect(described_class.get_label_list).to eq expected[:label]
    end
  end

  describe '#create' do
    let(:params) {
      {
        'subject'     => 'subject by rspec',
        'description' => 'description by rspec',
        'label'       => 2,
        'priority'    => 2,
      }
    }

    it 'Create correctly' do
      result = described_class.create(user_id, params)
      expect(result.nil?).to be false
      created_task_id = result

      result = described_class.get_task_by_id(user_id, created_task_id)
      expect(result['task'].nil?).to be false
      expect(result['task']).to be_an_instance_of(Task)
      expect(result['task'].user_id).to eq user_id
      expect(result['task'].subject).to eq params['subject']
      expect(result['task'].description).to eq params['description']
      expect(result['task'].label).to eq params['label']
      expect(result['task'].priority).to eq params['priority']
    end
  end

  describe '#update' do
    it 'Update correctly' do
      params_for_update = {
        'id' => task_a.id,
        'subject'     => 'subject update by rspec',
        'description' => 'description update by rspec',
        'state'       => 2,
        'label'       => 3,
        'priority'    => 3,
      }

      result = described_class.update(user_id, params_for_update)
      expect(result).to be true

      result = described_class.get_task_by_id(user_id, task_a.id)
      expect(result['task'].nil?).to be false
      expect(result['task']).to be_an_instance_of(Task)
      expect(result['task'].user_id).to eq user_id
      expect(result['task'].subject).to eq params_for_update['subject']
      expect(result['task'].description).to eq params_for_update['description']
      expect(result['task'].label).to eq params_for_update['label']
      expect(result['task'].priority).to eq params_for_update['priority']
    end

    it 'Target task is not found' do
      params_for_update = {
        'id'          => 9999999,
        'subject'     => 'subject update by rspec',
        'description' => 'description update by rspec',
        'state'       => 2,
        'label'       => 3,
        'priority'    => 3,
      }

      result = described_class.update(user_id, params_for_update)
      expect(result).to be false
    end
  end

  describe '#delete' do
    it 'Delete correctly' do
      described_class.delete(user_id, task_a.id)
      result = described_class.get_task_by_id(user_id, task_a.id)
      expect(result['task']).to be_nil
    end

    it 'Target task is not found' do
      not_exsits_task_id = 9999999
      result = described_class.delete(user_id, not_exsits_task_id)
      expect(result).to be false
    end
  end
end
