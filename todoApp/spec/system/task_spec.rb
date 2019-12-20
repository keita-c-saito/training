require 'rails_helper'

RSpec.describe 'Task management', type: :system, js: true do
  before do
    %w(first second).each do |nth|
      Task.create!(title: "rspec #{nth} task", description: 'rspec Description')
    end
  end

  scenario 'When user visit the tasks_path it shows the task list order by created recently' do
    visit tasks_path
    recent_title = find(:xpath, ".//table/tbody/tr[1]/td[1]").text
    old_title = find(:xpath, ".//table/tbody/tr[2]/td[1]").text
    expect(recent_title).to have_content 'rspec second task'
    expect(old_title).to have_content 'rspec first task'
  end

  scenario 'When user click New Task link it creates new task.' do
    visit tasks_path
    click_link 'New Task'
    fill_in 'Title', :with => 'My Task'
    fill_in 'Description', :with => 'My Task Description'
    click_button 'Create Task'
    expect(page).to have_content 'Task was successfully created.'
  end

  scenario 'When user click Edit link it updates the selected task.' do
    visit tasks_path
    first(:link, 'Edit').click
    fill_in 'Title', :with => 'My Edited Task'
    fill_in 'Description', :with => 'Edit My Task Description'
    click_button 'Update Task'
    expect(page).to have_content 'Task was successfully updated.'
  end

  scenario 'When user click Destroy link it deletes the selected task.' do
    visit tasks_path
    accept_alert do
      first(:link, 'Destroy').click
    end
    expect(page).to have_content 'Task was successfully destroyed.'
  end

end
