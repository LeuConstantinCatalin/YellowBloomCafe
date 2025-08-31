class AdminController < ApplicationController
  before_action -> { require_roles('admin') }

  def index
    per = 10

    @users_total = User.count
    @users_pages = (@users_total.to_f / per).ceil
    @users_page = [[params[:users_page].to_i, 1].max, [@users_pages, 1].max].min
    @users = User.order(email_verified: :asc, username: :asc).offset((@users_page - 1) * per).limit(per)
    @products = Product.order(:category, :name)


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

  def destroy_user
    u = User.find(params[:id])
    if u.id == current_user.id
      redirect_to admin_path, alert: "Nu poți șterge propriul cont." and return
    end
    begin
      u.destroy!
      redirect_to admin_path, notice: "Utilizatorul a fost șters."
    rescue => e
      redirect_to admin_path, alert: e.message
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :nume, :prenume, :email, :password, :password_confirmation)
  end
end
