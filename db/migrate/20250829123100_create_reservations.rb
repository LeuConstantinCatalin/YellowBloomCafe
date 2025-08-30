class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :dining_table, null: true, foreign_key: true
      t.datetime :starts_at, null: false
      t.integer :duration_minutes, null: false, default: 90
      t.integer :seats, null: false, default: 2
      t.string :status, null: false, default: 'requested'
      t.timestamps
    end
    add_index :reservations, :status
    add_index :reservations, :starts_at
  end
end

