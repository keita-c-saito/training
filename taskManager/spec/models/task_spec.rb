require 'rails_helper'

RSpec.describe Task, type: :model do
  context '登録テスト' do
    it "タスク名、説明、ユーザID、優先度があれば有効な状態であること" do
      expect(FactoryBot.build(:task)).to be_valid
    end
    it "タスク名が無ければ、無効な状態であること" do
      task = FactoryBot.build(:task, task_name: nil)
      task.valid?
      expect(task.errors[:task_name]).to include("タスク名が空です。")
    end
    it "説明が無ければ、無効な状態であること" do
      task = FactoryBot.build(:task, description: nil)
      task.valid?
      expect(task.errors[:description]).to include("説明が空です。")
    end
    it "ユーザIDが無ければ、無効な状態であること" do
      task = FactoryBot.build(:task, user_id: nil)
      task.valid?
      expect(task.errors[:user_id]).to include("ユーザIDが空です。")
    end
    it "優先度が無ければ、無効な状態であること" do
      task = FactoryBot.build(:task, priority: nil)
      task.valid?
      expect(task.errors[:priority]).to include("優先度が空です。")
    end
    it "ステータスが無ければ、無効な状態であること" do
      task = FactoryBot.build(:task, status: nil)
      task.valid?
      expect(task.errors[:status]).to include("ステータスが空です。")
    end
    it "ユーザIDが存在しなければ、無効な状態であること" do
      user = FactoryBot.create(:user)
      expect do
        FactoryBot.create(:task, user_id: user.id + 100)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
  # TODO: 検索機能が現状ないので後で実装する
  context "検索関連テスト(１項目)" do
    it "全件検索ができる"
    it "タスク名検索ができる"
    it "説明検索ができる"
    it "期限で検索ができる"
    it "優先度で検索ができる"
    it "ステータスで検索ができる"
    it "1つのラベルで検索ができる"
    it "複数件のラベルで検索ができる"
    it "登録日時の降順で検索できること(STEP10)の課題" do
      user = FactoryBot.create(:user)

      # order by created_at descの場合(task2 -> task3 -> task1の順番になるはず)
      task1 = FactoryBot.create(:task, user_id: user.id, created_at: "2018-05-20 14:00:00")
      task2 = FactoryBot.create(:task, user_id: user.id, created_at: "2018-05-21 15:00:00")
      task3 = FactoryBot.create(:task, user_id: user.id, created_at: "2018-05-20 14:02:00")

      expect(Task.all).to eq [task2, task3, task1]
    end
  end
  context "検索関連テスト(複数項目)" do
    it "タスク名とステータスで検索ができる"
    it "説明と期限で検索ができる"
    it "優先度とラベルで検索ができる"
  end
end
