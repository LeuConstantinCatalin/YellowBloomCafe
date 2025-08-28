# Seed products, ingredients, and recipes for the Menu page.

require "active_support/core_ext/numeric/bytes"

puts "Seeding ingredients..."
ingredients = {
  "cafea macinata" => { stock_quantity: 1000, unit: "g" },
  "apa"            => { stock_quantity: 10000, unit: "ml" },
  "lapte"          => { stock_quantity: 5000, unit: "ml" },
  "spuma lapte"    => { stock_quantity: 1000, unit: "ml" },
  "caramel"        => { stock_quantity: 800, unit: "ml" },
  "ciocolata"      => { stock_quantity: 1500, unit: "g" },
  "zahar"          => { stock_quantity: 2000, unit: "g" },
  "lamaie"         => { stock_quantity: 200, unit: "buc" },
  "menta"          => { stock_quantity: 300, unit: "g" },
  "iaurt"          => { stock_quantity: 3000, unit: "ml" },
  "fructe de padure" => { stock_quantity: 2500, unit: "g" },
  "mango"          => { stock_quantity: 1000, unit: "g" },
  "ananas"         => { stock_quantity: 1200, unit: "g" },
  "apa de cocos"   => { stock_quantity: 1000, unit: "ml" },
  "avocado"        => { stock_quantity: 300, unit: "buc" },
  "banana"         => { stock_quantity: 400, unit: "buc" },
  "piersici"       => { stock_quantity: 1200, unit: "g" },
  "miere"          => { stock_quantity: 600, unit: "ml" }
}

ingredient_records = {}
ingredients.each do |name, attrs|
  ingredient_records[name] = Ingredient.find_or_create_by!(name: name) do |ing|
    ing.stock_quantity = attrs[:stock_quantity]
    ing.unit = attrs[:unit]
  end
end

puts "Seeding products and recipes..."
def upsert_product(name:, category:, price:, description: nil)
  Product.find_or_create_by!(name: name, category: category) do |p|
    p.price = price
    p.description = description
  end
end

def recipe_for(product, items, ingredient_records)
  items.each do |ingredient_name, quantity|
    ProductIngredient.find_or_create_by!(product: product, ingredient: ingredient_records.fetch(ingredient_name)) do |pi|
      pi.quantity = quantity
    end
  end
end

# Cafele
espresso = upsert_product(name: "Espresso", category: "Cafele", price: 10)
recipe_for(espresso, {
  "cafea macinata" => 7,
  "apa" => 30
}, ingredient_records)

cappuccino = upsert_product(name: "Cappuccino", category: "Cafele", price: 14)
recipe_for(cappuccino, {
  "cafea macinata" => 7,
  "lapte" => 180,
  "spuma lapte" => 40
}, ingredient_records)

latte = upsert_product(name: "Latte", category: "Cafele", price: 15)
recipe_for(latte, {
  "cafea macinata" => 7,
  "lapte" => 220
}, ingredient_records)

caramel_macchiato = upsert_product(name: "Caramel Macchiato", category: "Cafele", price: 17)
recipe_for(caramel_macchiato, {
  "lapte" => 200,
  "cafea macinata" => 7,
  "caramel" => 30
}, ingredient_records)

mocha = upsert_product(name: "Mocha", category: "Cafele", price: 18)
recipe_for(mocha, {
  "cafea macinata" => 7,
  "lapte" => 200,
  "ciocolata" => 25
}, ingredient_records)

# Prajituri (exemple minimale, fara retete exacte)
cheesecake = upsert_product(name: "Cheesecake", category: "Prajituri", price: 16)
brownie    = upsert_product(name: "Brownie cu ciocolata", category: "Prajituri", price: 14)
mousse     = upsert_product(name: "Mousse de ciocolata", category: "Prajituri", price: 12)
tarta_lamaie = upsert_product(name: "Tarta cu lamaie", category: "Prajituri", price: 15)
tarta_frumi  = upsert_product(name: "Tarta cu fructe de padure", category: "Prajituri", price: 18)

# Bauturi racoritoare
citronada = upsert_product(name: "Citronada", category: "Bauturi racoritoare", price: 8)
recipe_for(citronada, {
  "lamaie" => 1,
  "zahar" => 10,
  "apa" => 250
}, ingredient_records)

ceai_iced = upsert_product(name: "Ceai Iced", category: "Bauturi racoritoare", price: 10)
recipe_for(ceai_iced, {
  "apa" => 300,
  "menta" => 5,
  "zahar" => 10
}, ingredient_records)

limonada_menta = upsert_product(name: "Limonada cu menta", category: "Bauturi racoritoare", price: 9)
recipe_for(limonada_menta, {
  "lamaie" => 1,
  "menta" => 5,
  "apa" => 300
}, ingredient_records)

smoothie_frumi = upsert_product(name: "Smoothie de fructe de padure", category: "Bauturi racoritoare", price: 12)
recipe_for(smoothie_frumi, {
  "fructe de padure" => 150,
  "iaurt" => 150
}, ingredient_records)

apa_minerala = upsert_product(name: "Apa minerala", category: "Bauturi racoritoare", price: 5)
recipe_for(apa_minerala, {
  "apa" => 500
}, ingredient_records)

# Smoothie-uri
sm_banana_capsuni = upsert_product(name: "Smoothie banane si capsuni", category: "Smoothie-uri", price: 14)
recipe_for(sm_banana_capsuni, {
  "banana" => 1,
  "fructe de padure" => 100,
  "iaurt" => 150
}, ingredient_records)

sm_tropical = upsert_product(name: "Smoothie tropical", category: "Smoothie-uri", price: 15)
recipe_for(sm_tropical, {
  "mango" => 150,
  "ananas" => 150,
  "apa de cocos" => 100
}, ingredient_records)

sm_avocado = upsert_product(name: "Smoothie de avocado", category: "Smoothie-uri", price: 16)
recipe_for(sm_avocado, {
  "avocado" => 1,
  "banana" => 1,
  "iaurt" => 150
}, ingredient_records)

sm_piersici = upsert_product(name: "Smoothie de piersici", category: "Smoothie-uri", price: 14)
recipe_for(sm_piersici, {
  "piersici" => 200,
  "iaurt" => 150,
  "miere" => 15
}, ingredient_records)

puts "Gata seed!"
