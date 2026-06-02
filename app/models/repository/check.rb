# # frozen_string_literal: true

# class Repository::Check < ApplicationRecord
#   include AASM

#   belongs_to :repository

#   validates :commit_id, presence: true, on: :update
#   validates :repository, presence: true

#   aasm column: :aasm_state do
#     state :created, initial: true
#     state :fetching
#     state :linting
#     state :finished
#     state :failed

#     event :start_fetch do
#       transitions from: :created, to: :fetching
#     end

#     event :start_lint do
#       transitions from: :fetching, to: :linting
#     end

#     event :finish do
#       transitions from: :linting, to: :finished
#     end

#     event :fail do
#       transitions from: %i[fetching created linting], to: :failed
#     end
#   end

#   def issues_count
#     return 0 if check_log.blank?
    
#     # Если check_log хранит JSON с результатами Rubocop
#     begin
#       parsed = JSON.parse(check_log)
#       parsed.dig('summary', 'offense_count') || 0
#     rescue JSON::ParserError
#       0
#     end
#   end

#     # Алиас для совместимости с кодом, который ожидает lint_output
#   def lint_output
#     check_log
#   end

#   def lint_output=(value)
#     self.check_log = value
#   end
#   # def passed?
#   #   finished? && issues_count.to_i.zero?
#   # end

#   # def failed_with_issues?
#   #   finished? && issues_count.to_i.positive?
#   # end
# end

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