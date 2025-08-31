class Product < ApplicationRecord
  has_many :product_ingredients, dependent: :destroy
  has_many :ingredients, through: :product_ingredients

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :category, presence: true

  def available?
    availability_with
  end

  def ingredient_list
    product_ingredients.includes(:ingredient).map { |pi| pi.ingredient&.name }.compact.join(", ")
  end


  def availability_with(overrides = {})
    product_ingredients.includes(:ingredient).all? do |pi|
      ing = pi.ingredient
      next false unless ing
      stock = overrides.key?(ing.id) ? overrides[ing.id].to_d : ing.stock_quantity.to_d
      stock >= pi.quantity.to_d
    end
  end
end
