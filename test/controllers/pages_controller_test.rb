require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get about_us" do
    get :about_us
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
