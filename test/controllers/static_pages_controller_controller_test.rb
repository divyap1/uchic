require 'test_helper'

class StaticPagesControllerControllerTest < ActionController::TestCase
  test "should get about" do
    get :about
    assert_response :success
  end

  test "should get contact_us" do
    get :contact_us
    assert_response :success
  end

  test "should get welcome" do
    get :welcome
    assert_response :success
  end

  test "should get faq" do
    get :faq
    assert_response :success
  end

end
