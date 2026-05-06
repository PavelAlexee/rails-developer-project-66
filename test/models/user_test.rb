require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:john)
  end

  test "должен быть валидным" do
    assert @user.valid?
  end

  test "email должно присутствовать" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end
end
