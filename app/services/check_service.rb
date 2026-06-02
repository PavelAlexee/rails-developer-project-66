# # # frozen_string_literal: true

# # require 'tmpdir'
# # require 'json'

# # class CheckService
# #   def initialize(check, linter_api: nil)
# #     @check = check
# #     @repository = check.repository
# #     # Если linter_api не передан, создаём новый экземпляр
# #     @linter_api = linter_api || LinterApi.new
# #   end

# #   def call
# #     @check.start_fetch!
# #     fetch_repository
# #     @check.start_lint!
# #     run_linter
# #     @check.finish!
# #   rescue StandardError => e
# #     handle_error(e)
# #     false
# #   end

# #   private

# #   def fetch_repository
# #     @tmpdir = Dir.mktmpdir
    
# #     # Вызываем метод clone_repository
# #     _stdout, stderr, status = @linter_api.clone_repository(@repository.clone_url, @tmpdir)

# #     unless status.success?
# #       raise "Git clone failed: #{stderr}"
# #     end

# #     commit_id = @linter_api.fetch_commit_hash(@tmpdir)
# #     @check.update(commit_id: commit_id)
# #   end

# #   def run_linter
# #     linter_config = Rails.root.join('.rubocop.yml')
# #     result = @linter_api.run_check(@tmpdir, linter_config.to_s)

# #     @check.update(
# #       check_log: result[:stdout],
# #       passed: calculate_issues_count(result[:stdout]).zero?
# #     )
# #   end

# #   def handle_error(error)
# #     # Безопасно переводим в состояние failed
# #     if @check.may_fail?
# #       @check.fail!
# #     elsif @check.persisted?
# #       @check.update_column(:aasm_state, 'failed')
# #     end
    
# #     # Сохраняем ошибку в check_log
# #     error_message = "Error: #{error.message}\n\nBacktrace:\n#{error.backtrace&.first(3)&.join("\n")}"
# #     @check.update(check_log: error_message)
    
# #     # Очистка временной директории
# #     cleanup
# #   end

# #   def calculate_issues_count(output)
# #     return 0 if output.blank?
    
# #     begin
# #       parsed = JSON.parse(output)
# #       parsed.dig('summary', 'offense_count') || 0
# #     rescue JSON::ParserError
# #       0
# #     end
# #   end

# #   def cleanup
# #     FileUtils.rm_rf(@tmpdir) if @tmpdir && Dir.exist?(@tmpdir)
# #   end
# # end


# # app/services/check_service.rb
# require 'tmpdir'
# require 'json'
# require 'open3'

# class CheckService
#   def initialize(check)
#     @check = check
#     @repository = check.repository
#     @linter_api = LinterApi.new
#   end

#   def call
#     debugger
#     # Шаг 1: Начинаем клонирование
#     @check.start_fetch!
#     @check.save!  # Важно! Сохраняем состояние в БД
#     Rails.logger.info "Check #{@check.id} state after start_fetch: #{@check.aasm_state}"
    
#     # Шаг 2: Клонируем репозиторий
#     fetch_repository
    
#     # Шаг 3: Начинаем линтинг
#     @check.start_lint!
#     @check.save!  # Важно! Сохраняем состояние в БД
#     Rails.logger.info "Check #{@check.id} state after start_lint: #{@check.aasm_state}"
    
#     # Шаг 4: Запускаем линтер
#     run_linter
    
#     # Шаг 5: Завершаем проверку
#     @check.finish!
#     @check.save!  # Важно! Сохраняем состояние в БД
    
#     true
#   rescue StandardError => e
#     Rails.logger.error "CheckService error: #{e.message}"
#     handle_error(e)
#     false
#   ensure
#     cleanup
#   end

#   private

#   def fetch_repository
#     @tmpdir = Dir.mktmpdir
#     Rails.logger.info "Cloning repository to #{@tmpdir}"
    
#     _stdout, stderr, status = @linter_api.clone_repository(@repository.clone_url, @tmpdir)

#     unless status.success?
#       raise "Git clone failed: #{stderr}"
#     end

#     commit_id = @linter_api.fetch_commit_hash(@tmpdir)
#     Rails.logger.info "Commit hash: #{commit_id}"
    
#     @check.update(commit_id: commit_id)
#     Rails.logger.info "Check #{@check.id} updated with commit_id"
#   end

#   def run_linter
#     linter_config = Rails.root.join('.rubocop.yml')
#     Rails.logger.info "Running linter on #{@tmpdir}"
    
#     result = @linter_api.run_check(@tmpdir, linter_config.to_s)

#     issues_count = calculate_issues_count(result[:stdout])
#     Rails.logger.info "Issues count: #{issues_count}"

#     @check.update(
#       check_log: result[:stdout],
#       passed: issues_count.zero?
#     )
#   end

#   def calculate_issues_count(output)
#     return 0 if output.blank?
    
#     JSON.parse(output).dig('summary', 'offense_count') || 0
#   rescue JSON::ParserError
#     0
#   end

#   def handle_error(error)
#     Rails.logger.error "Handling error: #{error.message}"
    
#     # Пытаемся перевести в состояние failed, если это возможно
#     if @check.may_fail?
#       @check.fail!
#       @check.save!
#     else
#       # Если нельзя перейти в failed (например, из created), обновляем напрямую
#       @check.update_column(:aasm_state, 'failed')
#     end
    
#     @check.update(check_log: "Error: #{error.message}")
#   end

#   def cleanup
#     FileUtils.rm_rf(@tmpdir) if @tmpdir && Dir.exist?(@tmpdir)
#   end
# end




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
    # Начинаем проверку
    @check.start!
    @check.save!
    Rails.logger.info "Check #{@check.id} started"

    # Клонируем репозиторий
    fetch_repository
    
    # Запускаем линтер
    run_linter
    
    # Завершаем проверку
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

    unless status.success?
      raise "Git clone failed: #{stderr}"
    end

    commit_id = @linter_api.fetch_commit_hash(@tmpdir)
    Rails.logger.info "Commit hash: #{commit_id}"
    
    @check.update(commit_id: commit_id)
  end

  # def run_linter
  #   linter_config = Rails.root.join('.rubocop.yml')
  #   Rails.logger.info "Running linter on #{@tmpdir}"
    
  #   result = @linter_api.run_check(@tmpdir, linter_config.to_s)

  #   issues_count = calculate_issues_count(result[:stdout])
  #   Rails.logger.info "Issues count: #{issues_count}"

  #   # Сохраняем результат проверки
  #   @check.update(
  #     check_log: result[:stdout],
  #     passed: issues_count.zero?
  #   )
  # end

  def run_linter
    linter_config = Rails.root.join('.rubocop.yml')
    Rails.logger.info "Running linter on #{@tmpdir}"
    
    result = @linter_api.run_check(@tmpdir, linter_config.to_s)
    
    # Отладка
    Rails.logger.info "RuboCop stdout: #{result[:stdout]}"
    Rails.logger.info "RuboCop stderr: #{result[:stderr]}"
    Rails.logger.info "RuboCop exit status: #{result[:exit_status]}"
    
    issues_count = calculate_issues_count(result[:stdout])
    Rails.logger.info "Issues count: #{issues_count}"

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