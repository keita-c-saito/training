# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Authentication', type: :feature do
  let!(:maintenance_config) { create(:maintenance_config) }
  let(:user) { create(:user, account: 'account', password: 'password') }

  feature 'signup' do
    before do
      visit signup_path
    end

    scenario 'user can signup' do
      fill_in 'ユーザ名（表示用）', with: 'new_name'
      fill_in 'アカウント', with: 'new_account'
      fill_in 'パスワード', with: 'password'
      click_button '送信'

      expect(page).to have_text('ユーザを作成しました')
    end

    scenario 'user cannot signup with existing account' do
      fill_in 'ユーザ名（表示用）', with: 'new_name'
      fill_in 'アカウント', with: user.account
      fill_in 'パスワード', with: 'password'
      click_button '送信'

      expect(page).to have_text('アカウントはすでに存在します')
    end

    scenario 'user cannot signup with account length lt 4' do
      fill_in 'ユーザ名（表示用）', with: 'new_name'
      fill_in 'アカウント', with: 'a' * 3
      fill_in 'パスワード', with: 'password'
      click_button '送信'

      expect(page).to have_text('アカウントは4文字以上で入力してください')
    end

    scenario 'user cannot signup without password' do
      fill_in 'ユーザ名（表示用）', with: 'new_name'
      fill_in 'アカウント', with: 'new_account'
      fill_in 'パスワード', with: ''
      click_button '送信'

      expect(page).to have_text('パスワードを入力してください')
    end

    scenario 'user cannot signup with password length lt 4' do
      fill_in 'ユーザ名（表示用）', with: 'a' * 3
      fill_in 'アカウント', with: 'new_account'
      fill_in 'パスワード', with: 'a' * 3
      click_button '送信'

      expect(page).to have_text('パスワードは4文字以上で入力してください')
    end
  end

  feature 'login' do
    before do
      visit login_path
    end

    scenario 'user can login' do
      fill_in 'アカウント', with: user.account
      fill_in 'パスワード', with: 'password'
      click_button 'ログイン'

      expect(page).to have_text("ログイン中:#{user.name}")
    end

    scenario 'user can not login with wrong account' do
      fill_in 'アカウント', with: 'wrong_account'
      fill_in 'パスワード', with: user.password
      click_button 'ログイン'

      expect(page).to have_text('アカウントかパスワードが間違っています')
    end

    scenario 'user can not login with wrong password' do
      fill_in 'アカウント', with: 'account'
      fill_in 'パスワード', with: 'wrong_password'
      click_button 'ログイン'

      expect(page).to have_text('アカウントかパスワードが間違っています')
    end
  end

  feature 'logout' do
    before do
      visit login_path

      fill_in 'アカウント', with: user.account
      fill_in 'パスワード', with: 'password'
      click_button 'ログイン'
    end

    scenario 'user can logout' do
      visit root_path

      click_link 'ログアウト'

      expect(page).to have_text('ログアウトしました')
    end
  end
end
