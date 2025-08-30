class HomeController < ApplicationController
  before_action :redirect_employee_to_dashboard, if: -> { current_user&.employee? }

  def index
  end
end
