require "test_helper"

class AngajatControlsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get angajat_controls_index_url
    assert_response :success
  end
end
