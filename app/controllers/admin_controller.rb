class AdminController < ApplicationController
  before_action -> { require_roles('admin') }

  def index
    @users = User.order(:username)
    @products = Product.order(:category, :name)

    # Basic site stats/performance proxies
    @stats = {
      users_total: User.count,
      users_by_role: User.group(:tip).count,
      orders_total: Order.count,
      orders_pending: Order.where(status: 'pending').count,
      orders_completed: Order.where(status: 'completed').count,
      reservations_total: Reservation.count,
      reservations_requested: Reservation.where(status: 'requested').count,
      products_total: Product.count,
      ingredients_total: Ingredient.count
    }
  end

  # Create employee or manager accounts
  def create_user
    u = User.new(user_params)
    allowed = %w[angajat manager]
    role = params[:user][:tip].to_s
    u.tip = allowed.include?(role) ? role : 'angajat'
    if u.save
      redirect_to admin_path, notice: "Utilizator creat (#{u.tip})."
    else
      redirect_to admin_path, alert: u.errors.full_messages.join(', ')
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :nume, :prenume, :email, :password, :password_confirmation)
  end
end

