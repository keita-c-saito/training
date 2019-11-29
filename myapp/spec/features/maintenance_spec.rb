# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'maintenance', type: :feature do
  given!(:user) { create(:admin_user, account: 'tadashi.toyokura', password: 'password') }
  given!(:maintenance_config) { create(:maintenance_config) }

  feature 'maintenance on' do
    background do
      maintenance_config.update(enabled: :on)
    end

    scenario 'visiting when maintenance on' do
      visit root_path
      expect(page).to have_text('メンテナンス中です')
      visit admin_users_path
      expect(page).to have_text('メンテナンス中です')
      visit signup_path
      expect(page).to have_text('メンテナンス中です')
      visit login_path
      expect(page).to have_text('メンテナンス中です')
    end
  end
end
