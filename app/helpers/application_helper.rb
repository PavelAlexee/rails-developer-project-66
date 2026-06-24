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

  def check_state_name(check)
    case check.aasm_state
    when 'created'
      t('checks.states.created')
    when 'in_process'
      t('checks.states.in_process')
    when 'finished'
      check.passed? ? t('checks.states.passed') : t('checks.states.failed')
    when 'failed'
      t('checks.states.error')
    else
      check.aasm_state
    end
  end
end
