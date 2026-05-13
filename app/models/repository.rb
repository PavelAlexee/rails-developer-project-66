# frozen_string_literal: true

class Repository < ApplicationRecord

  extend Enumerize 
  
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
end
