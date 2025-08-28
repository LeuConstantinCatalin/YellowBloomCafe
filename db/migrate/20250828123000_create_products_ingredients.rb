class CreateProductsIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 8, scale: 2, default: 0
      t.string :category, null: false
      t.string :image_url
      t.integer :position
      t.timestamps
    end
    add_index :products, :category

    create_table :ingredients do |t|
      t.string :name, null: false
      t.decimal :stock_quantity, precision: 10, scale: 2, default: 0, null: false
      t.string :unit, default: "unit"
      t.timestamps
    end
    add_index :ingredients, :name, unique: true

    create_table :product_ingredients do |t|
      t.references :product, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.timestamps
    end
    add_index :product_ingredients, [:product_id, :ingredient_id], unique: true
  end
end

