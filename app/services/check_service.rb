# frozen_string_literal: true

require 'tmpdir'
require 'json'
require 'open3'

class CheckService
  def initialize(check)
    @check = check
    @repository = check.repository
    @linter_api = LinterApi.new
  end

  def call
    @check.start!
    @check.save!
    Rails.logger.info "Check #{@check.id} started"

    fetch_repository

    run_linter

    @check.finish!
    @check.save!
    Rails.logger.info "Check #{@check.id} finished successfully"

    true
  rescue StandardError => e
    Rails.logger.error "CheckService error: #{e.message}"
    handle_error(e)
    false
  ensure
    cleanup
  end

  private

  def fetch_repository
    @tmpdir = Dir.mktmpdir
    Rails.logger.info "Cloning repository to #{@tmpdir}"

    _stdout, stderr, status = @linter_api.clone_repository(@repository.clone_url, @tmpdir)

    raise "Git clone failed: #{stderr}" unless status.success?

    commit_id = @linter_api.fetch_commit_hash(@tmpdir)
    Rails.logger.info "Commit hash: #{commit_id}"

    @check.update(commit_id: commit_id)
  end

  def run_linter
    linter_config = Rails.root.join('.rubocop.yml')

    result = @linter_api.run_check(@tmpdir, linter_config.to_s)

    issues_count = calculate_issues_count(result[:stdout])

    @check.update(
      check_log: result[:stdout],
      passed: issues_count.zero?
    )
  end

  def calculate_issues_count(output)
    return 0 if output.blank?

    JSON.parse(output).dig('summary', 'offense_count') || 0
  rescue JSON::ParserError
    0
  end

  def handle_error(error)
    @check.fail!
    @check.save!
    @check.update(check_log: "Error: #{error.message}")
  end

  def cleanup
    FileUtils.rm_rf(@tmpdir) if @tmpdir && Dir.exist?(@tmpdir)
  end
end
