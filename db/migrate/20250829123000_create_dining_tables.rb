class CreateDiningTables < ActiveRecord::Migration[7.1]
  def change
    create_table :dining_tables do |t|
      t.string :name, null: false
      t.integer :seats, null: false, default: 2
      t.timestamps
    end
    add_index :dining_tables, :name, unique: true
  end
end

