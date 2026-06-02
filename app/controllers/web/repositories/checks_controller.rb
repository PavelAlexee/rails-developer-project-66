# frozen_string_literal: true

class Web::Repositories::ChecksController < Web::Repositories::ApplicationController
  before_action :authenticate_user!
  before_action :set_repository
  before_action :set_check, only: [:show]

  def create
    check = @repository.checks.create!
    CheckService.new(check).call

    redirect_to repository_path(@repository), notice: t('flash.checks.created')
  end

  def show
    @parsed_output = parse_lint_output(@check.check_log)
  end

  private

  def set_repository
    @repository = current_user.repositories.find(params[:repository_id])
  end

  def set_check
    @check = @repository.checks.find(params[:id])
  end

  def parse_lint_output(output)
    return {} if output.blank?

    JSON.parse(output)
  rescue JSON::ParserError
    { raw_output: output }
  end
end
