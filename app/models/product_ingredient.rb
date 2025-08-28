class ProductIngredient < ApplicationRecord
  belongs_to :product
  belongs_to :ingredient

  validates :quantity, numericality: { greater_than: 0 }
end

