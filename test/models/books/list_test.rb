require "test_helper"

class Books::ListTest < ActiveSupport::TestCase
  setup do
    # Clear and seed specific data for sorting/filtering tests
    Book.delete_all

    # 1. Available book, older
    @apple = Book.create!(
      title: "Apple Guide",
      status: :available,
      created_at: 2.days.ago
    )

    # 2. Available book, newer
    @zebra = Book.create!(
      title: "Zebra Manual",
      status: :available,
      created_at: 1.day.ago
    )

    # 3. Reserved book (must include email due to validation)
    @banana = Book.create!(
      title: "Banana Recipe",
      status: :reserved,
      reserved_by_email: "banana@fruit.com",
      created_at: 3.days.ago
    )
  end

  # --- Filtering Tests ---

  test "should filter by status" do
    params = { filters: { status: "reserved" } }
    results = Books::List.new.execute(**params)

    assert_equal 1, results.size
    assert_equal "Banana Recipe", results.first.title
  end

  test "should search by title fragment" do
    params = { filters: { query: "Zeb" } }
    results = Books::List.new.execute(**params)

    assert_equal 1, results.size
    assert_equal "Zebra Manual", results.first.title
  end

  # --- Sorting Tests ---

  test "should sort by status asc and title asc (simultaneous sorting)" do
    # 'available' (0) comes before 'reserved' (1)
    # 'Apple' (A) comes before 'Zebra' (Z)
    params = {
      order: { "status" => "asc", "title" => "asc" }
    }
    results = Books::List.new.execute(**params)

    assert_equal "Apple Guide", results[0].title
    assert_equal "Zebra Manual", results[1].title
    assert_equal "Banana Recipe", results[2].title
  end

  test "should sort by title descending" do
    params = { order: { "title" => "desc" } }
    results = Books::List.new.execute(**params)

    assert_equal "Zebra Manual", results.first.title
    assert_equal "Apple Guide", results.last.title
  end

  # --- Security & Fallback Tests ---

  test "should fallback to default sort when provided with invalid columns" do
    # 'not_a_column' should be ignored by the allowlist
    params = { order: { "not_a_column" => "asc" } }
    results = Books::List.new.execute(**params)

    # Default is created_at DESC, so the newest book (@zebra) should be first
    assert_equal @zebra.id, results.first.id
  end

  test "should handle empty params gracefully" do
    results = Books::List.new.execute
    assert_equal 3, results.size
    # Default sort check (created_at DESC)
    assert_equal @zebra.id, results.first.id
  end
end
