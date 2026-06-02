# frozen_string_literal: true

require 'open3'
require 'json'
require 'tmpdir'

class LinterApi
  def clone_repository(clone_url, path)
    stdout, stderr, status = Open3.capture3('git', 'clone', clone_url, path)
    [stdout, stderr, status]
  end

  def run_check(repository_path, linter_config_path = nil)
    command = build_rubocop_command(repository_path, linter_config_path)
    stdout, stderr, status = Open3.capture3(*command)
    {
      stdout: stdout,
      stderr: stderr,
      exit_status: status.exitstatus
    }
  end

  def fetch_commit_hash(repo_path)
    stdout, _stderr, status = Open3.capture3('git', '-C', repo_path, 'rev-parse', 'HEAD')
    status.success? ? stdout.strip : nil
  end

  private

  def build_rubocop_command(repository_path, linter_config_path)
    cmd = ['bundle', 'exec', 'rubocop', '--format', 'json']
    cmd += ['-c', linter_config_path] if linter_config_path
    cmd << repository_path
    cmd
  end
end
