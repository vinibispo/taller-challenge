class AddIndexToBooks < ActiveRecord::Migration[8.1]
  def change
    add_index :books, %i[status title]
    add_index :books, :created_at
  end
end
