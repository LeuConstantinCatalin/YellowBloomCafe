# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_28_123000) do
  create_table "ingredients", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "stock_quantity", precision: 10, scale: 2, default: "0.0", null: false
    t.string "unit", default: "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_ingredients_on_name", unique: true
  end

  create_table "product_ingredients", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "ingredient_id", null: false
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_product_ingredients_on_ingredient_id"
    t.index ["product_id", "ingredient_id"], name: "index_product_ingredients_on_product_id_and_ingredient_id", unique: true
    t.index ["product_id"], name: "index_product_ingredients_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 8, scale: 2, default: "0.0"
    t.string "category", null: false
    t.string "image_url"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_products_on_category"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "nume"
    t.string "prenume"
    t.date "data_nastere"
    t.string "email"
    t.string "password_digest"
    t.string "tip"
    t.string "adresa"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "email_verified", default: false, null: false
    t.string "email_verification_code"
    t.datetime "email_verification_sent_at"
  end

  add_foreign_key "product_ingredients", "ingredients"
  add_foreign_key "product_ingredients", "products"
end
