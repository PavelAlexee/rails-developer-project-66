# frozen_string_literal: true

module ApplicationHelper
  def flash_class(level)
    case level.to_sym
    when :notice
      'success'
    when :alert, :error
      'danger'
    when :warning
      'warning'
    else
      'info'
    end
  end
end