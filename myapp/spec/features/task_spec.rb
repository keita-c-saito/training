# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Task', type: :feature do
  let!(:maintenance_config) { create(:maintenance_config) }
  let!(:user) { create(:user) }
  let!(:labels) do
    2.times do |index|
      create(:label, name: "label-#{index}")
    end
    Label.all
  end

  before do
    visit login_path
    fill_in 'アカウント', with: 'tadashi.toyokura'
    fill_in 'パスワード', with: 'password'
    click_button 'ログイン'
  end

  feature 'creation' do
    context 'with valid name (length le 50)' do
      scenario 'user can create a new task' do
        visit new_task_path
        fill_in '名前', with: 'a' * 50
        click_button '送信'
        expect(page).to have_text('新しいタスクを作成しました')
      end

      scenario 'user can create a new task with deadline' do
        visit new_task_path
        fill_in '名前', with: 'a' * 50
        fill_in '終了期限', with: Date.tomorrow.to_s
        click_button '送信'
        expect(page).to have_text('新しいタスクを作成しました')
      end
    end

    context 'with invalid name (length over 50)' do
      scenario 'user can not create a new task' do
        visit new_task_path
        fill_in '名前', with: 'a' * 51
        click_button '送信'
        expect(page).to have_text('名前は50文字以内')
      end
    end

    context 'with invalid name (empty string)' do
      scenario 'user can not create a new task' do
        visit new_task_path
        fill_in '名前', with: ''
        click_button '送信'
        expect(page).to have_text('名前を入力してください')
      end
    end

    context 'with labels' do
      scenario 'user can create a new task with labels.' do
        visit new_task_path
        fill_in '名前', with: 'a'
        check labels[0].name
        check labels[1].name
        click_button '送信'
        expect(page).to have_text(labels[0].name)
        expect(page).to have_text(labels[1].name)
      end
    end
  end

  feature 'modification' do
    let(:task) { create(:task, name: 'mytask-to-edit', description: 'description', status: 'todo', user: user) }

    scenario 'user can add labels to a task.' do
      visit edit_task_path(task)
      check labels[0].name
      check labels[1].name
      click_button '送信'
      expect(page).to have_text(labels[0].name)
      expect(page).to have_text(labels[1].name)
    end

    feature 'edit labels' do
      let!(:new_label) { create(:label, name: 'label-new') }

      before do
        task.labels = labels
      end

      scenario 'user can change labels of a task' do
        visit edit_task_path(task)
        check new_label.name
        uncheck labels[0].name
        click_button '送信'
        expect(page).to_not have_text(labels[0].name)
        expect(page).to have_text(new_label.name)
      end
    end

    scenario 'user can edit a task' do
      visit edit_task_path(task)
      name_edited = 'mytask-spec-edited'
      fill_in '名前', with: name_edited
      fill_in '説明', with: 'edited-description'
      select '進行中', from: 'task_status'
      click_button '送信'
      expect(page).to have_text('タスクを更新しました')
      expect(page).to have_text(name_edited)
    end

    scenario 'user can edit a task deadline' do
      visit edit_task_path(task)
      fill_in '終了期限', with: (Date.tomorrow + 1).to_s
      click_button '送信'
      expect(page).to have_text('タスクを更新しました')
    end

    scenario 'user can not edit a task with invalid name (empty string)' do
      visit edit_task_path(task)
      fill_in '名前', with: ''
      click_button '送信'
      expect(page).to have_text('名前を入力してください')
    end

    scenario 'user can not edit a task with invalid name (length over 50)' do
      visit edit_task_path(task)
      fill_in '名前', with: 'a' * 51
      click_button '送信'
      expect(page).to have_text('名前は50文字以内')
    end
  end

  feature 'show' do
    let(:task) { create(:task, name: 'mytask', description: 'mydescription', status: 'todo', user: user) }

    scenario 'user can see detail of a task' do
      visit task_path(task)
      expect(page).to have_text(task.name)
      expect(page).to have_text(task.description)
      expect(page).to have_text(task.readable_status)
      expect(page).to have_text(task.readable_deadline)
    end
  end

  feature 'deletion' do
    let(:task) { create(:task, name: 'task-to-delete', description: 'description', user: user) }

    scenario 'user can delete a task' do
      visit task_path(task)
      click_link '削除'
      expect(page).to have_text('タスクを削除しました')
      expect(page).not_to have_text(task.name)
    end
  end

  feature 'listing' do
    feature 'sorting' do
      let!(:above_task) { create(:task, name: 'above-task', description: 'description', deadline: (Time.zone.today + 2).to_s, user: user) }
      let(:below_task) { create(:task, name: 'below-task', description: 'description', deadline: (Time.zone.today + 1).to_s, user: user) }

      before do
        below_task.update(created_at: Time.current.advance(days: -1))
        visit root_path
      end

      scenario 'user can lists tasks order by created_at desc' do
        expect(page.body.index(below_task.name)).to be > page.body.index(above_task.name)
      end

      scenario 'user can sort tasks by deadline desc' do
        click_link '終了期限:↓'
        expect(page.body.index(above_task.name)).to be < page.body.index(below_task.name)
      end

      scenario 'user can sort tasks by deadline asc' do
        click_link '終了期限:↓'
        click_link '終了期限:↑'
        expect(page.body.index(above_task.name)).to be > page.body.index(below_task.name)
      end
    end

    feature 'own tasks' do
      let(:other_user) { create(:user, account: 'other') }
      let(:others_task) { create(:task, name: 'others-task', user: other_user) }

      scenario 'user can list only own tasks.' do
        visit root_path
        expect(page).to_not have_text(others_task.name)
      end
    end
  end

  feature 'search' do
    let!(:todo_task1) { create(:task, name: 'task1-todo', description: 'tmp', status: 'todo', user: user) }
    let!(:todo_task2) { create(:task, name: 'task2-todo', description: 'tmp', status: 'todo', user: user) }
    let!(:done_task1) { create(:task, name: 'task1-done', description: 'tmp', status: 'done', user: user) }

    before do
      todo_task1.labels = [labels[0]]
      todo_task2.labels = [labels[1]]
    end

    context 'with status' do
      scenario 'user can search tasks' do
        visit root_path
        select '未着手', from: 'status'
        click_button '検索'
        expect(page).not_to have_text(done_task1.name)
        expect(page).to have_text(todo_task1.name)
        expect(page).to have_text(todo_task2.name)
      end
    end

    context 'with name' do
      scenario 'user can search tasks' do
        visit root_path
        fill_in 'name', with: 'done'
        click_button '検索'
        expect(page).to have_text(done_task1.name)
        expect(page).not_to have_text(todo_task1.name)
        expect(page).not_to have_text(todo_task2.name)
      end
    end

    context 'with labels' do
      scenario 'user can search tasks' do
        visit root_path
        check labels[0].name
        check labels[1].name
        click_button '検索'
        expect(page).to have_text(todo_task1.name)
        expect(page).to have_text(todo_task2.name)
        expect(page).not_to have_text(done_task1.name)
      end
    end

    context 'with name ,status and a label' do
      scenario 'user can search tasks' do
        visit root_path
        fill_in 'name', with: '1-todo'
        select '未着手', from: 'status'
        check todo_task1.labels.first.name
        click_button '検索'
        expect(page).not_to have_text(done_task1.name)
        expect(page).to have_text(todo_task1.name)
        expect(page).not_to have_text(todo_task2.name)
      end

      scenario 'search params will remains on form' do
        visit root_path
        fill_in 'name', with: 'no-task-found-name'
        select '進行中', from: 'status'
        check labels[0].name
        click_button '検索'
        expect(page).to have_selector('input[value=no-task-found-name]')
        expect(page).to have_selector('option[selected=selected][value=processing]')
        expect(page).to have_selector("input[type=checkbox][id=#{labels[0].name}]")
      end
    end
  end

  feature 'pagination' do
    let(:todo_name) { 'todo-task' }
    let(:good_done_name) { 'good-done-task' }
    let(:well_done_name) { 'well-done-task' }

    before do
      create(:task, name: todo_name, status: 'todo', user: user)
      5.times do
        create(:task, name: good_done_name, status: 'done', user: user)
        create(:task, name: well_done_name, status: 'done', user: user)
      end
      visit root_path
      fill_in 'name', with: 'well-done'
      select '完了', from: 'status'
      click_button '検索'
    end

    feature 'search' do
      context 'when first page' do
        scenario 'there is only 2 well done tasks' do
          expect(page).to have_content(well_done_name, count: 2)
          expect(page).not_to have_content(todo_name)
          expect(page).not_to have_content(good_done_name)
        end
      end

      context 'when middle page' do
        scenario 'there is only 2 well done tasks' do
          click_link '次'
          expect(page).to have_content(well_done_name, count: 2)
          expect(page).not_to have_content(todo_name)
          expect(page).not_to have_content(good_done_name)
        end
      end

      context 'when last page' do
        scenario 'there is only 1 well done task' do
          click_link '最後'
          expect(page).to have_content(well_done_name, count: 1)
          expect(page).not_to have_content(todo_name)
          expect(page).not_to have_content(good_done_name)
        end
      end
    end
  end
end
