# frozen_string_literal: true

class LinterApiStub
  def clone_repository(_clone_url, _path)
    ['', '', double(success?: true, exitstatus: 0)]
  end

  def run_check(_repository_path, _linter_config_path = nil)
    {
      stdout: '{"metadata":{"rubocop_version":"1.50.0"},"files":[],"summary":{"offense_count":0,"target_file_count":1,"inspected_file_count":1}}',
      stderr: '',
      exit_status: 0
    }
  end

  def fetch_commit_hash(_repo_path)
    'abc123def456789012345678901234567890abcd'
  end
end
