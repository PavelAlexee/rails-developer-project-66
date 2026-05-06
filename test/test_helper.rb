ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
    
    include FactoryBot::Syntax::Methods if defined?(FactoryBot)
  end
end

module SignInHelper
  def sign_in_as(user)
    session[:user_id] = user.id
  end
  
  def sign_out
    session[:user_id] = nil
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
