class Ingredient < ApplicationRecord
  has_many :product_ingredients, dependent: :destroy
  has_many :products, through: :product_ingredients

  validates :name, presence: true, uniqueness: true
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }

  after_update_commit :broadcast_availability_flips, if: :saved_change_to_stock_quantity?

  private

  def broadcast_availability_flips
    before, after = saved_change_to_stock_quantity
    return if before.nil? || after.nil?

    overrides_before = { id => before }
    # Compare availability for each affected product
    products.includes(product_ingredients: :ingredient).each do |product|
      prev_available = product.availability_with(overrides_before)
      curr_available = product.available?
      next if prev_available == curr_available

      ActionCable.server.broadcast(
        "product_availability",
        { product_id: product.id, available: curr_available }
      )
    end
  end
end
