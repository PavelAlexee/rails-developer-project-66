# frozen_string_literal: true

class GithubApiStub
  def initialize(_token); end

  def repos
    [OpenStruct.new(id: 123, name: 'test-ruby-repo', full_name: 'user/test-ruby-repo',
                    language: 'Ruby', clone_url: 'https://github.com/user/test-ruby-repo.git',
                    ssh_url: 'git@github.com:user/test-ruby-repo.git')]
  end

  def repo(id)
    OpenStruct.new(id: id, name: 'test-ruby-repo', full_name: 'user/test-ruby-repo',
                   language: 'Ruby', clone_url: 'https://github.com/user/test-ruby-repo.git',
                   ssh_url: 'git@github.com:user/test-ruby-repo.git')
  end

  def user_repos
    repos
  end

  def repo_commits(_full_name)
    [OpenStruct.new(sha: 'abc123def456', commit: OpenStruct.new(message: 'Initial commit'))]
  end
end
