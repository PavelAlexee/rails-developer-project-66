# frozen_string_literal: true

require 'test_helper'

class Web::RepositoriesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:john)
    sign_in(@user)
  end
  
  test '#index' do
    get repositories_path
    
    assert_response :success
  end

  # test '#new' do
  #   get new_repository_path

  #   assert_response :success
  # end
end
