require "test_helper"

class Books::ReserveTest < ActiveSupport::TestCase
  test "should handle concurrent reservation attempts gracefully" do
    book = Book.create!(title: "Concurrency in Ruby", status: "available")

    results = []
    threads = []

    2.times do |i|
      threads << Thread.new do
        # Crucial: Give each thread its own DB connection from the pool
        ActiveRecord::Base.connection_pool.with_connection do
          service = Books::Reserve.new(book.id)
          results << service.execute!("user#{i}@example.com")
        end
      end
    end

    threads.each(&:join)

    # Extract statuses from your service return: [data, status, error]
    statuses = results.map { |r| r[1] }

    assert_includes statuses, :ok, "One attempt must succeed"
    assert_includes statuses, :conflict, "The other attempt must be rejected with conflict"

    book.reload
    assert_equal "reserved", book.status
    assert_not_nil book.reserved_by_email
  end
end
