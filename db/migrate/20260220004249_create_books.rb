class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :status, null: false, default: "available"
      t.string :title, null: false
      t.string :reserved_by_email, null: true
      t.check_constraint "status IN ('available', 'reserved', 'checked_out')", name: "status_check"


      t.timestamps
    end
  end
end
