class Task < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }
  validates :user_id, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :priority, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :label_id, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
  validate :end_date_valid?

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
end
