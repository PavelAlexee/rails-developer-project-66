# frozen_string_literal: true

class Repository < ApplicationRecord
  extend Enumerize

  has_many :checks, class_name: 'Repository::Check', dependent: :destroy

  belongs_to :user

  enumerize :language, in: %i[ruby], predicates: true, default: :ruby

  validates :github_id, presence: true

  def self.from_github(repo_data, user)
    find_or_initialize_by(github_id: repo_data.id, user: user).tap do |repository|
      repository.name = repo_data.name
      repository.full_name = repo_data.full_name
      repository.language = repo_data.language&.downcase
      repository.clone_url = repo_data.clone_url
      repository.ssh_url = repo_data.ssh_url
      repository.user = user
    end
  end

  def last_check
    checks.order(created_at: :desc).first
  end

  def last_check_status
    last_check&.aasm_state
  end

  def github_url
    "https://github.com/#{full_name}"
  end
  
  def commit_url(commit_hash)
    "#{github_url}/commit/#{commit_hash}" if commit_hash.present?
  end
end
