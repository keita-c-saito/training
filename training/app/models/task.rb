class Task < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { maximum: 255 }
  validates :user_id, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :label_id, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
  validate :end_date_valid?

  enum status: { not_started: 0, underway: 1, done: 2 }
  validates :status, presence: true, inclusion: { in: Task.statuses.keys }

  enum priority: { low: 0, middle: 1, high: 2 }
  validates :priority, presence: true, inclusion: { in: Task.priorities.keys }

  def self.search(params)
    result = case params[:order]
             when 'end_date_asc', 'end_date_desc' 
               self.order(end_date: order_option(params[:order]))
             when 'priority_asc', 'priority_desc'
               self.order(priority: order_option(params[:order]))
             else
               self.order(created_at: :desc)
             end

    result = result.where(status: params[:status]) if params[:status].present?
    result = result.where(name: params[:name]) if params[:name].present?
    if params[:user].present?
      result = result.where(user_id: params[:user][:only_self_task]) if params[:user][:only_self_task].present?
    end
    result
  end

  private

  def end_date_valid?
    # ActiveRecordによって強制的にcastされる値('abc'など)はnilになるので
    # end_date_before_type_castが存在してend_dateがnullなら不正な値として除外する
    if end_date_before_type_cast.present? && end_date.nil?
      errors.add(:end_date, I18n.t('errors.messages.end_date.invalid'))
      return false
    end

    if date_valid?(end_date)
      return true
    else
      errors.add(:end_date, I18n.t('errors.messages.end_date.not_exist'))
      return false
    end
  end

  def date_valid?(date)
    return true if date.nil? || date.instance_of?(Date)
    !! Date.parse(date) rescue false
  end

  def self.order_option(str)
    %w(end_date_asc priority_asc).include?(str) ? :asc : :desc
  end
end
