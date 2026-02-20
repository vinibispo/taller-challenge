require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    25.times { |i| Book.create!(title: "Book #{i}", status: :available) }
  end

  test "index should return paginated results and headers" do
    get books_url, params: { page: 1 }
    assert_response :success

    json = JSON.parse(response.body)
    # Assuming Pagy default is 20
    assert_equal 20, json.size
    assert_not_nil response.headers["Total-Count"]
  end

  test "index should handle complex filter and order params" do
    get books_url, params: {
      filters: { status: "available" },
      order: { title: "desc" }
    }
    assert_response :success
  end
end
