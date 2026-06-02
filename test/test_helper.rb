# ENV['RAILS_ENV'] ||= 'test'
# require_relative '../config/environment'
# require 'rails/test_help'

# OmniAuth.config.test_mode = true
# OmniAuth.config.request_validation_phase = nil

# module ActiveSupport
#   class TestCase
#     parallelize(workers: :number_of_processors)
#     fixtures :all
    
#     include FactoryBot::Syntax::Methods if defined?(FactoryBot)
#   end
# end

# module SignInHelper
#   def sign_in(user, _options = {})
#     auth_hash = {
#       provider: 'github',
#       uid: user.nickname,
#       info: {
#         email: user.email,
#         name: user.name,
#         nickname: user.nickname,
#         image: user.image_url
#       },
#       credentials: {
#         token: user.token
#       }
#     }

#     OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash::InfoHash.new(auth_hash)

#     get callback_auth_url('github')
#   end

#   def signed_in?
#     session[:user_id].present? && current_user.present?
#   end

#   def current_user
#     @current_user ||= User.find_by(id: session[:user_id])
#   end
# end

# class ActionDispatch::IntegrationTest
#   include SignInHelper
# end


ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'

WebMock.disable_net_connect!

Dir[Rails.root.join('test/stubs/**/*.rb')].each { |f| require f }

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