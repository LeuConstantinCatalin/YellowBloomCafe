class MenuController < ApplicationController
  before_action :redirect_employee_to_dashboard, if: -> { current_user&.employee? }
  def index
    products = Product.includes(product_ingredients: :ingredient).all


    grouped = products.group_by(&:category)
    @products_by_category = grouped.transform_values do |list|
      list.sort_by { |p| [p.available? ? 0 : 1, p.name.to_s.downcase] }
    end

    if current_user
      @my_orders = current_user.orders.includes(order_items: :product).order(created_at: :desc)
      @my_reservations = current_user.reservations.includes(:dining_table).order(starts_at: :desc)
    end
  end
end
