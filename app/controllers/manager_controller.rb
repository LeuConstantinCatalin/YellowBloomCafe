class ManagerController < ApplicationController
  before_action -> { require_roles('manager','admin') }

  def index
    per = 10
    # Products/recipes pagination
    @products_total = Product.count
    @products_pages = (@products_total.to_f / per).ceil
    @products_page = [[params[:products_page].to_i, 1].max, [@products_pages, 1].max].min
    @products = Product.order(:category, :name).offset((@products_page - 1) * per).limit(per)

    # Reviews pagination
    @reviews_total = Review.count
    @reviews_pages = (@reviews_total.to_f / per).ceil
    @reviews_page = [[params[:reviews_page].to_i, 1].max, [@reviews_pages, 1].max].min
    @reviews = Review.includes(:user).order(created_at: :desc).offset((@reviews_page - 1) * per).limit(per)

    # Messages pagination
    @messages_total = Message.count
    @messages_pages = (@messages_total.to_f / per).ceil
    @messages_page = [[params[:messages_page].to_i, 1].max, [@messages_pages, 1].max].min
    @messages = Message.includes(:user).order(created_at: :desc).offset((@messages_page - 1) * per).limit(per)
    @ingredients = Ingredient.order(:name)
    @users = User.order(:username)

    # Simple stats
    @stats = {
      users_total: User.count,
      users_clients: User.where(tip: 'client').count,
      users_employees: User.where(tip: 'angajat').count,
      users_managers: User.where(tip: 'manager').count,
      orders_pending: Order.where(status: 'pending').count,
      orders_today: Order.where("created_at >= ?", Time.current.beginning_of_day).count,
      reservations_requested: Reservation.where(status: 'requested').count
    }
  end

  # Products
  def create_product
    p = Product.new(product_params)
    if p.save
      redirect_to manager_path, notice: "Produs creat."
    else
      redirect_to manager_path, alert: p.errors.full_messages.join(', ')
    end
  end

  def update_product
    p = Product.find(params[:id])
    if p.update(product_params)
      redirect_to manager_path, notice: "Produs actualizat."
    else
      redirect_to manager_path, alert: p.errors.full_messages.join(', ')
    end
  end

  # Recipes (ProductIngredient)
  def add_recipe_item
    product = Product.find(params[:product_id])
    ingredient = Ingredient.find(params[:ingredient_id])
    quantity = params[:quantity]
    pi = ProductIngredient.find_or_initialize_by(product: product, ingredient: ingredient)
    pi.quantity = quantity
    if pi.save
      redirect_to manager_path, notice: "Ingredient adaugat/actualizat la retetã."
    else
      redirect_to manager_path, alert: pi.errors.full_messages.join(', ')
    end
  end

  def remove_recipe_item
    pi = ProductIngredient.find(params[:id])
    pi.destroy
    redirect_to manager_path, notice: "Ingredient scos din retetã."
  end

  # User management: create employee accounts
  def create_employee
    u = User.new(user_params)
    u.tip = 'angajat'
    if u.save
      redirect_to manager_path, notice: "Cont angajat creat."
    else
      redirect_to manager_path, alert: u.errors.full_messages.join(', ')
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :category, :price, :description)
  end

  def user_params
    params.require(:user).permit(:username, :nume, :prenume, :email, :password, :password_confirmation)
  end
end
