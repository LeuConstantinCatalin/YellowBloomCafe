class EmployeeControlsController < ApplicationController
  def index
    @ingredients = Ingredient.order(:name)
  end

  def update_ingredient
    ing = Ingredient.find(params[:id])
    if ing.update(ingredient_params)
      redirect_to employee_path, notice: "Stoc actualizat pentru #{ing.name}."
    else
      redirect_to employee_path, alert: ing.errors.full_messages.join(', ')
    end
  end

  private

  def ingredient_params
    params.require(:ingredient).permit(:stock_quantity)
  end
end

