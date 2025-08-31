class OrdersController < ApplicationController
  protect_from_forgery with: :exception

  def create
    unless current_user
      render json: { error: 'Trebuie să fii autentificat.' }, status: :unauthorized and return
    end

    items = params[:items].to_a.map do |it|
      { product_id: it[:product_id] || it['product_id'], quantity: (it[:quantity] || it['quantity']).to_i }
    end

    if items.blank? || items.any? { |i| i[:product_id].blank? || i[:quantity] <= 0 }
      render json: { error: 'Coș invalid.' }, status: :unprocessable_entity and return
    end

    # Determine address
    address = current_user.adresa.presence
    if address.blank?
      address = params[:address].to_s.strip
      if address.blank?
        render json: { error: 'Adresa este necesară pentru finalizare.' }, status: :unprocessable_entity and return
      end

      current_user.update(adresa: address)
    end

    product_ids = items.map { |i| i[:product_id].to_i }
    products = Product.includes(product_ingredients: :ingredient).where(id: product_ids).index_by(&:id)


    total = 0.to_d
    items.each do |it|
      p = products[it[:product_id].to_i]
      unless p
        render json: { error: "Produs inexistent: ##{it[:product_id]}" }, status: :unprocessable_entity and return
      end
      price = (p.price || 0).to_d
      total += price * it[:quantity].to_i
    end

    required = Hash.new(0.to_d) 
    items.each do |it|
      p = products[it[:product_id].to_i]
      qty = it[:quantity].to_i
      p.product_ingredients.each do |pi|
        required[pi.ingredient_id] += (pi.quantity || 0).to_d * qty
      end
    end


    order = nil
    shortages = []
    ActiveRecord::Base.transaction do

      ingredients = Ingredient.lock.where(id: required.keys).index_by(&:id)
      required.each do |ing_id, need|
        ing = ingredients[ing_id]
        have = (ing&.stock_quantity || 0).to_d
        shortages << { name: (ing&.name || "Ingredient ##{ing_id}"), need: need, have: have } if have < need
      end

      break if shortages.any?


      required.each do |ing_id, need|
        ing = ingredients[ing_id]
        ing.update!(stock_quantity: (ing.stock_quantity.to_d - need))
      end

      order = Order.create!(user: current_user, status: 'pending', address: address, total: total)
      items.each do |it|
        p = products[it[:product_id].to_i]
        OrderItem.create!(order: order, product: p, quantity: it[:quantity], unit_price: p.price || 0)
      end
    end

    if shortages.any?
      list = shortages.map { |s| "#{s[:name]} (necesar #{s[:need].to_s('F')}, disponibil #{s[:have].to_s('F')})" }.join(", ")
      render json: { error: "Stoc ingrediente insuficient: #{list}" }, status: :unprocessable_entity and return
    end

    render json: { ok: true, order_id: order.id }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
  rescue => e
    Rails.logger.error("Order create failed: #{e.class} #{e.message}\n#{e.backtrace.join("\n")}")
    render json: { error: 'A apărut o eroare la plasarea comenzii.' }, status: :internal_server_error
  end
end
