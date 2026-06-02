# frozen_string_literal: true

class GithubApi
  def initialize(token)
    @client = Octokit::Client.new(access_token: token, auto_paginate: true)
  end

  def repos
    @client.repos
  end

  def repo(id)
    @client.repo(id)
  end

  def user_repos
    repos = @client.repos
    repos.select { |repo| repo.language&.downcase == 'ruby' }
  end

  def repo_commits(full_name)
    @client.commits(full_name)
  rescue Octokit::NotFound
    []
  end
end
