# frozen_string_literal: true

class Web::RepositoriesController < Web::ApplicationController
  before_action :authenticate_user!
  before_action :set_github_repos, only: [:new, :create]

  def index
    @repositories = current_user.repositories
  end

  def show
    @repository = current_user.repositories.find(params[:id])
  end

  def new
    @repository = Repository.new
  end

  def create
    if @github_repos.blank?
      redirect_to new_repository_path, alert: t('flash.repositories.no_repos_found')
      return
    end
    
    github_id = params.dig(:repository, :github_id)&.to_i
    
    if github_id.nil?
      redirect_to new_repository_path, alert: t('flash.repositories.no_repo_selected')
      return
    end
    
    repo_data = @github_repos.find { |r| r.id == github_id }
    
    if repo_data.nil?
      redirect_to new_repository_path, alert: t('flash.repositories.not_found')
      return
    end
    
    @repository = Repository.from_github(repo_data, current_user)
    
    if @repository.save
      redirect_to repositories_path, notice: t('flash.repositories.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    repository = current_user.repositories.find(params[:id])
    repository.destroy
    redirect_to repositories_path, notice: t('flash.repositories.destroyed')
  end

  private

  def set_github_repos
    @github_repos = []
    
    return unless current_user&.token

    client = Octokit::Client.new(access_token: current_user.token, auto_paginate: true)
    repos = client.repos
    
    @github_repos = repos.select { |repo| repo.language&.downcase == 'ruby' }
  rescue Octokit::Unauthorized
    redirect_to root_path, alert: t('flash.repositories.github_auth_error') and return
  rescue Octokit::TooManyRequests
    redirect_to repositories_path, alert: t('flash.repositories.rate_limit') and return
  rescue StandardError => e
    redirect_to repositories_path, alert: t('flash.repositories.github_error', error: e.message) and return
  end
end
