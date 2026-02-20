# 📚 Book Management System (API)

A high-performance Ruby on Rails API for managing book reservations, designed to handle large datasets and concurrent requests.

## 🚀 Key Features

* **Concurrency Control:** Uses database-level pessimistic locking to prevent double-booking.
* **Optimized Listing:** Handles large datasets using bulk-loading techniques and indexed filtering.
* **Command Pattern:** Decoupled business logic from controllers for better testability and maintenance.
* **Multi-Column Sorting:** Secure, allowlist-based simultaneous sorting (e.g., sort by status AND title).

---

## 🏗️ Architecture & Design Patterns

### 1. Service/Command Objects

Instead of bloating the `Book` model or the `BooksController`, all logic is encapsulated in:

* `Books::List`: Manages complex filtering, searching, and sorting.
* `Books::Reserve`: Manages the state machine and atomicity of book reservations.

### 2. Concurrency (Race Conditions)

To solve the "double-reservation" problem, the system uses `ActiveRecord`'s `#with_lock`.

This issues a `SELECT ... FOR UPDATE` (or the SQLite equivalent), ensuring that if two users click "Reserve" at the exact same millisecond, only one transaction succeeds while the other is gracefully rejected with a `:conflict` status.

### 3. Performance for Large Datasets

* **Database Indexing:** Composite indexes are implemented on `[:status, :title]` to ensure that filtered sorting remains  even with millions of rows.
* **Pagy Pagination:** Used for its low memory footprint compared to Kaminari/WillPaginate.
* **Selective Selection:** The API only selects the columns necessary for the view, reducing memory bloat.

---

## 🛠️ Security

* **SQL Injection Prevention:** Sorting parameters are validated against an internal `ALLOWED_SORT_COLUMNS` allowlist. Raw parameters are never interpolated directly into the `.order()` clause.
* **Input Sanitization:** Filters are applied using ActiveRecord's parameterized queries.

---

## 🧪 Testing

The suite includes:

* **Unit Tests:** For the `Books::List` logic.
* **Integration Tests:** Ensuring the API contract (JSON structure and HTTP headers).
* **Concurrency Tests:** A multi-threaded test case that simulates simultaneous requests to verify the locking mechanism.

Run the tests with:

```bash
bin/rails test

```

---

## 💾 Setup & Seeding

The seed file is optimized using `insert_all` to populate the database with 50,000+ records in seconds.

1. **Install dependencies:** `bundle install`
2. **Setup database:** `bin/rails db:setup` (This runs migrations and seeds)
3. **Run server:** `bin/rails s`

---

### API Usage Examples

**Filtered & Sorted List:**
`GET /books?filters[status]=available&order[status]=asc&order[title]=desc`

**Reservation:**
`POST /books/:id/reserve`

*Payload:* `{ "email": "user@example.com" }`