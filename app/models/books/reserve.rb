class Books::Reserve
  private attr_accessor :book_id
  def initialize(book_id)
      self.book_id = book_id
  end

  def execute!(email)
    book = Book.find_by(id: book_id)
    return nil, :not_found, "Book not found" if book.nil?

    book.with_lock do
      if book.reserved?
          return nil, :conflict, "Book is already reserved"
      end

      if book.checked_out?
        return nil, :conflict, "Book is checked out"
      end

      book.status = "reserved"
      book.reserved_by_email = email
      return book, :ok, nil if book.save

      return nil, :unprocessable_entity, book.errors.full_messages.join(", ")
    end
  end
end
