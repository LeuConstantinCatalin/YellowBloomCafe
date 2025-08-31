class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user
  helper_method :user_role
  helper PaginationHelper

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def user_role
    current_user&.role
  end

  private

  # Require at least one of the allowed roles; redirect to root if unauthorized
  def require_roles(*roles)
    unless current_user && roles.map(&:to_s).include?(current_user.role)
      redirect_to root_path, alert: "Nu ai permisiune pentru aceastã paginã."
    end
  end

  # If logged in as employee-only, keep them on the Employee page
  def redirect_employee_to_dashboard
    if current_user&.employee?
      redirect_to employee_path
    end
  end
end
