require 'rails_helper'

RSpec.describe "Admin::Users", type: :system do

  let(:administrator) { create(:administrator) }
  let(:user) { create(:user) }

  describe 'when access index' do
    context 'with logged-in user' do
      it 'success to show admin users page' do
        log_in_as administrator
        visit admin_users_path
        expect(page.current_path).to eq('/admin/users')
        expect(page).to have_content('administrator')
      end

      it 'success to click link' do
        log_in_as administrator
        visit admin_users_path
        click_on 'Add New User'
        expect(page.current_path).to eq('/admin/users/new')
      end
    end

    context 'with logged-out user' do
      it 'failed to access' do
        visit admin_users_path
        expect(page.current_path).not_to eq('/admin/users')
      end
    end
  end

  describe 'when access show' do
    context 'with logged-in user' do
      it 'success to access' do
        log_in_as administrator
        visit admin_user_path(administrator)
        expect(page.current_path).to eq("/admin/users/#{ administrator.id }")
        expect(page).to have_content('administrator')
      end
    end

    context 'with logged-out user' do
      it 'failed to access' do
        visit admin_user_path(administrator)
        expect(page.current_path).not_to eq("/admin/users/#{ administrator.id }")
      end
    end
  end

  describe 'when access new' do
    context 'with logged-in user' do
      it 'success to access' do
        log_in_as administrator
        visit new_admin_user_path
        expect(page.current_path).to eq("/admin/users/new")
      end

      it 'success to add new user' do
        log_in_as administrator
        visit new_admin_user_path
        fill_in 'user_name', with: 'test_user'
        fill_in 'user_password', with: 'test_password'
        fill_in 'user_password_confirmation', with: 'test_password'
        click_on '登録'
        expect(page.current_path).to eq('/admin/users')
        expect(page).to have_content 'Success!'
      end
    end

    context 'with logged-out user' do
      it 'failed to access' do
        visit new_admin_user_path
        expect(page.current_path).not_to eq('/admin/users/new')
      end
    end
  end
end
