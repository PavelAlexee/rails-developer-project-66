require 'test_helper'

class Web::HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:john)
  end

  test "should get show" do
    get root_path
    assert_response :success
    assert_template :show
  end
end
