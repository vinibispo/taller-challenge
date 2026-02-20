class BooksController < ApplicationController
  include Pagy::Method
  def index
    # Expected params structure:
    # { filters: { status: 'available' }, order: { status: 'asc', title: 'desc' } }

    books_query = Books::List.new.execute(
      filters: params[:filters],
      order: params[:order]
    )
    pagy, books = pagy(books_query)
    headers = pagy.headers_hash()
    response.headers.merge!(headers)
    render json: books, status: :ok
  end
end
