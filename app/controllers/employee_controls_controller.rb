class EmployeeControlsController < ApplicationController
  before_action -> { require_roles('angajat','manager','admin') }
  def index
    per = 10

    @ingredients_total = Ingredient.count
    @ingredients_pages = (@ingredients_total.to_f / per).ceil
    @ingredients_page = [[params[:ingredients_page].to_i, 1].max, [@ingredients_pages, 1].max].min
    @ingredients = Ingredient.order(:name).offset((@ingredients_page - 1) * per).limit(per)

    @recipes_total = Product.count
    @recipes_pages = (@recipes_total.to_f / per).ceil
    @recipes_page = [[params[:recipes_page].to_i, 1].max, [@recipes_pages, 1].max].min
    @products = Product.includes(product_ingredients: :ingredient).order(:category, :name).offset((@recipes_page - 1) * per).limit(per)
    @orders = Order.includes(order_items: :product).where(status: ["pending", "confirmed"]).order(created_at: :desc)
    @dining_tables = DiningTable.includes(:reservations).order(:name)
    @reservation_requests = Reservation.where(status: 'requested').order(:starts_at)
  end

  def update_ingredient
    ing = Ingredient.find(params[:id])
    if ing.update(ingredient_params)
      redirect_to employee_path, notice: "Stoc actualizat pentru #{ing.name}."
    else
      redirect_to employee_path, alert: ing.errors.full_messages.join(', ')
    end
  end

  def confirm_order
    order = Order.find(params[:id])
    unless order.status == 'pending'
      redirect_to employee_path, alert: 'Comanda nu este în stare validă pentru confirmare.' and return
    end
    order.update!(status: 'confirmed')
    redirect_to employee_path, notice: 'Comanda a fost confirmată.'
  end

  def complete_order
    order = Order.find(params[:id])
    unless order.status == 'confirmed'
      redirect_to employee_path, alert: 'Doar comenzile confirmate pot fi finalizate.' and return
    end
    order.update!(status: 'completed')
    redirect_to employee_path, notice: 'Comanda a fost finalizată.'
  end

  def assign_reservation
    reservation = Reservation.find(params[:id])
    table = DiningTable.find(params[:table_id])
    unless reservation.status == 'requested'
      render json: { error: 'Rezervarea nu este în stare de atribuire.' }, status: :unprocessable_entity and return
    end

    # Check overlap
    temp = Reservation.new(id: reservation.id, starts_at: reservation.starts_at, duration_minutes: reservation.duration_minutes)
    if temp.overlaps_for_table?(table)
      render json: { error: 'Interval indisponibil pentru această masă.' }, status: :unprocessable_entity and return
    end

    if reservation.seats > table.seats
      render json: { error: 'Numărul de locuri depășește capacitatea mesei.' }, status: :unprocessable_entity and return
    end

    reservation.update!(dining_table: table, status: 'assigned')

    render json: { ok: true }
  end

  def complete_reservation
    reservation = Reservation.find(params[:id])
    unless reservation.status == 'assigned'
      render json: { error: 'Doar rezervările asignate pot fi finalizate.' }, status: :unprocessable_entity and return
    end
    reservation.update!(status: 'completed')
    render json: { ok: true }
  end

  private

  def ingredient_params
    params.require(:ingredient).permit(:stock_quantity)
  end
end
