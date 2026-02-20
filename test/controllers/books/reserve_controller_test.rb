require "test_helper"
class Books::ReserveControllerTest < ActionController::TestCase
    test "should reserve a book successfully" do
        book = Book.create!(title: "Test Book", status: "available")
        post :execute, params: { book_id: book.id, email: "john@doe.com" }
        assert_response :ok
    end

    test "should not reserve a book that is already reserved" do
        book = Book.create!(title: "Test Book", status: "reserved", reserved_by_email: "jane@doe.com")
        post :execute, params: { book_id: book.id, email: "john@doe.com" }
        assert_response :conflict
    end

    test "should not reserve a non-existent book" do
        post :execute, params: { book_id: 999, email: "john@doe.com" }
        assert_response :not_found
    end

    test "should not reserve a book with invalid email" do
        book = Book.create!(title: "Test Book", status: "available")
        post :execute, params: { book_id: book.id, email: "invalid-email" }
        assert_response :unprocessable_entity
    end

    test "should not reserve a book that is checked out" do
        book = Book.create!(title: "Test Book", status: "checked_out")
        post :execute, params: { book_id: book.id, email: "john@doe.com" }
        assert_response :conflict
    end

    test "should handle unexpected errors gracefully" do
        # temporarily override the service method to simulate a crash
        original = Books::Reserve.instance_method(:execute!)
        Books::Reserve.class_eval do
          define_method(:execute!) do |email|
            raise "Unexpected error"
          end
        end

        book = Book.create!(title: "Test Book", status: "available")
        post :execute, params: { book_id: book.id, email: "john@doe.com" }
        assert_response :internal_server_error
      ensure
        # restore the original implementation so other tests are unaffected
        Books::Reserve.class_eval do
          define_method(:execute!, original)
        end
    end
end
