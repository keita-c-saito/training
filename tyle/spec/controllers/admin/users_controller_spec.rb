# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  render_views

  let(:user) { create(:admin_user) }
  let(:task) { create(:task, { user_id: user.id }) }
  let(:params) do
    {
      user: {
        name: 'user2',
        login_id: 'id2',
        password: 'password2',
        password_confirmation: 'password2',
        role: 'general',
      },
    }
  end
  let(:params2) do
    {
      id: user.id,
      user: {
        name: 'user2',
        login_id: 'id2',
        password: 'password2',
        password_confirmation: 'password2',
        role: 'administrator',
      },
    }
  end
  let(:params_without_name) do
    {
      user: {
        name: '',
        login_id: 'id2',
        password: 'password2',
        password_confirmation: 'password2',
        role: 'general',
      },
    }
  end
  let(:params2_without_login_id) do
    {
      id: user.id,
      user: {
        name: 'user2',
        login_id: '',
        password: 'password2',
        password_confirmation: 'password2',
        role: 'administrator',
      },
    }
  end

  # login
  before do
    remember_token = User.encrypt(cookies[:user_remember_token])
    cookies.permanent[:user_remember_token] = remember_token
    user.update!(remember_token: User.encrypt(remember_token))
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template('admin/users/index')
      expect(response.body).to have_content('ユーザーリスト')
      expect(response.body).to have_content('user1')
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
      expect(response).to render_template('admin/users/new')
      expect(response.body).to have_content('追加するユーザーの詳細を入力してください')
    end
  end

  describe 'POST #create' do
    context 'when user sends the correct parameters' do
      it 'returns the redirect to the user page' do
        post :create, params: params
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(admin_user_path(User.last))

        get :show, params: { id: User.last.id }
        expect(response).to have_http_status(:success)
        expect(response).to render_template('admin/users/show')
        expect(response.body).to have_content('ユーザーの詳細')
        expect(response.body).to have_content('user2')
      end
    end

    context 'when user sends parameters with empty name' do
      it 'returns http success' do
        post :create, params: params_without_name
        expect(response).to have_http_status(:success)
        expect(response).to render_template('admin/users/new')
      end
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: user.id }
      expect(response).to have_http_status(:success)
      expect(response).to render_template('admin/users/show')
      expect(response.body).to have_content('ユーザーの詳細')
      expect(response.body).to have_content('user1')
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { id: user.id }
      expect(response).to have_http_status(:success)
      expect(response).to render_template('admin/users/edit')
      expect(response.body).to have_content('編集するユーザーの詳細を入力してください')
    end
  end

  describe 'POST #update' do
    context 'when user sends the correct parameters' do
      it 'returns the redirect to the show page' do
        post :update, params: params2
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(admin_user_path(user))

        get :show, params: { id: user.id }
        expect(response).to have_http_status(:success)
        expect(response).to render_template('admin/users/show')
        expect(response.body).to have_content('ユーザーの詳細')
        expect(response.body).to have_content('user2')
      end
    end

    context 'when user sends parameters with empty login_id' do
      it 'returns http success' do
        post :update, params: params2_without_login_id
        expect(response).to have_http_status(:success)
        expect(response).to render_template('admin/users/edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user destroys another user' do
      let(:user2) { create(:user) }

      it 'returns the redirect to the index page' do
        delete :destroy, params: { id: user2.id }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(admin_users_path)

        # Waiting for the delete
        sleep 1

        get :show, params: { id: user2.id }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user destroys itself' do
      it 'returns the redirect to the user page' do
        delete :destroy, params: { id: user.id }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(admin_user_path(user))

        get :show, params: { id: user.id }
        expect(response).to have_http_status(:success)
        expect(response).to render_template('admin/users/show')
        expect(response.body).to have_content('自分自身は削除できません')
        expect(response.body).to have_content('user1')
      end
    end
  end
end
