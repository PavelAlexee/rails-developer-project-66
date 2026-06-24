# frozen_string_literal: true

class Repository::Check < ApplicationRecord
  include AASM

  belongs_to :repository

  validates :repository, presence: true

  aasm column: :aasm_state do
    state :created, initial: true
    state :in_process, :failed, :finished

    event :start do
      transitions from: :created, to: :in_process
    end

    event :fail do
      transitions from: :in_process, to: :failed
    end

    event :finish do
      transitions from: :in_process, to: :finished
    end
  end

  def issues_count
    return 0 if check_log.blank?

    begin
      parsed = JSON.parse(check_log)
      parsed.dig('summary', 'offense_count') || 0
    rescue JSON::ParserError
      0
    end
  end

  def with_issues?
    issues_count.positive?
  end

  def passed?
    finished? && !with_issues?
  end
end
