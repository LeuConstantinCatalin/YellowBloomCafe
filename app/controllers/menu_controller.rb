class MenuController < ApplicationController
  def index
    products = Product.includes(product_ingredients: :ingredient).all

    # Group by category and sort available first
    grouped = products.group_by(&:category)
    @products_by_category = grouped.transform_values do |list|
      list.sort_by { |p| [p.available? ? 0 : 1, p.name.to_s.downcase] }
    end
  end
end
