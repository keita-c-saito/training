# frozen_string_literal: true

module TasksHelper
  def toggled_sort_link(column, title = nil)
    title ||= t('.' + column)
    # ソートの状態を比較する
    direction = (params[:sort] == column && params[:direction] == 'asc') ? 'desc' : 'asc'
    link_to title, sort: column, direction: direction
  end
end
