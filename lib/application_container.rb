# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :github_api, -> { GithubApiStub }
    register :linter_api, -> { LinterApiStub }
  else
    register :github_api, -> { GithubApi }
    register :linter_api, -> { LinterApi }
  end

  # if Rails.env.test?
  #   register :octokit_client, -> { OctokitClientStub }
  #   register :linter, -> { LinterStub }
  #   register :check_service, -> { CheckServiceStub }
  # else
  #   register :octokit_client, -> { Octokit::Client }
  #   register :linter, -> { Linter::Linter }
  #   register :check_service, -> { Repository::CheckService }
  # end
end

Import = Dry::AutoInject(ApplicationContainer)

# class ApplicationContainer
#   extend Dry::Container::Mixin

#   if Rails.env.test?
#     register :github_api, ->(token) { GithubApiStub.new(token) }
#     register :linter_api, -> { LinterApiStub.new }
#   else
#     register :github_api, ->(token) { GithubApi.new(token) }
#     register :linter_api, -> { LinterApi.new }
#   end
# end

# Import = Dry::AutoInject(ApplicationContainer)