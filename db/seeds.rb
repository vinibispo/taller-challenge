puts "Cleaning database..."
Book.delete_all

puts "Generating 50,000 books..."

# We use an array of hashes to perform a bulk insert
books = []
statuses = [ :available, :reserved, :checked_out ]

50_000.times do |i|
  books << {
    title: "Book Title #{i}",
    status: statuses.sample,
    created_at: Time.current - rand(1..1000).days,
    updated_at: Time.current
  }

  # Insert in batches of 5000 to keep memory usage low
  if books.size >= 5000
    Book.insert_all(books)
    books = []
    print "."
  end
end

# Insert any remaining books
Book.insert_all(books) if books.any?

puts "\nSuccess! Created #{Book.count} books."
