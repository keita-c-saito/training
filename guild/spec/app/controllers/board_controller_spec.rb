require 'rails_helper'
require 'logic_board'

describe BoardController, type: :request do
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
  describe '#index' do
    context 'Not during maintenance' do
      it 'Displayed correctly' do
        get '/board/'
        expect(response).to have_http_status "200"
        expect(response.body).to include '<a class="navbar-brand" href="#" data-turbolinks="false">Guild</a>'
      end
    end
    context 'During maintenance' do
      it 'Displayed correctly' do
        create(:maintenance1)
        get '/board/'
        expect(response).to have_http_status "302"
        expect(response).to redirect_to controller: :maintenance, action: :index
        expect(response.body).to_not include '<h1>During Maintenance</h1>'
      end
    end
  end

  describe '#get_master' do
    it 'Displayed correctly' do
      get '/board/api/master/all'
      expect(response).to have_http_status "200"
      response_params = JSON.parse(response.body)
      expect(response_params['response']['state'].count).to be > 1
      expect(response_params['response']['priority'].count).to be > 1
      expect(response_params['response']['label'].count).to be > 1
    end
  end

  describe '#get_task_all' do
    context 'Condition used' do
      it 'Displayed correctly' do
        query_string = "?conditions%5Blabel%5D=#{task_b.label}&conditions%5Bstate%5D=#{task_b.state}";
        get '/board/api/task/all' + query_string
        expect(response).to have_http_status "200"
        response_params = JSON.parse(response.body)
        expect(response_params['response']['task_list'].count).to_not eq 0
        expect(response_params['response']['limit']).to eq LogicBoard::LIMIT
        expect(response_params['response']['total']).to eq 1
        task = response_params['response']['task_list'][0]
        expect(task['id']).to eq task_b.id
        expect(task['user_id']).to eq task_b.user_id
      end
    end
    context 'Condition not used' do
      it 'Displayed correctly' do
        get '/board/api/task/all'
        expect(response).to have_http_status "200"
        response_params = JSON.parse(response.body)
        expect(response_params['response']['task_list'].count).to_not eq 0
        expect(response_params['response']['limit']).to eq LogicBoard::LIMIT
        expect(response_params['response']['total']).to eq 2
        task = response_params['response']['task_list'][0]
        expect(task['id']).to eq task_a.id
        expect(task['user_id']).to eq task_a.user_id
      end
    end
  end

  describe '#get_task_by_id' do
    it 'Displayed correctly' do
      get '/board/api/task/' + task_a.id.to_s
      expect(response).to have_http_status "200"
      response_params = JSON.parse(response.body)
      expect(response_params['response']['task']['id']).to eq task_a.id
      expect(response_params['response']['task']['user_id']).to eq task_a.user_id
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
    it 'Displayed correctly' do
      post '/board/api/task', params: params
      expect(response).to have_http_status "200"
      response_params = JSON.parse(response.body)
      expect(response_params['result']).to_not eq 0
    end
  end

  describe '#delete' do
   let(:params) {
      {
        'subject'     => 'subject by rspec',
        'description' => 'description by rspec',
        'label'       => 3,
        'priority'    => 3,
      }
    }
    it 'Displayed correctly' do
      created_task_id = LogicBoard.create(task_a.user_id, params)
      delete '/board/api/task/' + created_task_id.to_s
      expect(response).to have_http_status "200"
      response_params = JSON.parse(response.body)
      expect(response_params['result']).to_not eq 0
    end
  end

  describe '#update' do
    let!(:create_params) {
      {
        'subject'     => 'subject by rspec',
        'description' => 'description by rspec',
        'label'       => 3,
        'priority'    => 3,
      }
    }

    let!(:update_params) {
      {
        'subject'     => 'updated subject',
        'description' => 'updated description',
        'label'       => 3,
        'priority'    => 3,
        'state'       => 3,
      }
    }

    it 'Displayed correctly' do
      created_task_id = LogicBoard.create(task_a.user_id, create_params)
      put '/board/api/task/' + created_task_id.to_s, params: update_params
      expect(response).to have_http_status "200"
      response_params = JSON.parse(response.body)
      expect(response_params['result']).to_not eq 0
    end
  end
end
