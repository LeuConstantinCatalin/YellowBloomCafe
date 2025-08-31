class ReviewsController < ApplicationController
  def create
    unless current_user
      redirect_to account_path, alert: "Trebuie să fii autentificat." and return
    end
    unless current_user.client? || current_user.admin?
      redirect_to root_path, alert: "Doar clienții sau adminii pot lăsa recenzii aici." and return
    end
    r = current_user.reviews.build(review_params)
    if r.save
      redirect_to account_path, notice: "Recenzie adăugată. Mulțumim!"
    else
      redirect_to account_path, alert: r.errors.full_messages.join(', ')
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :content)
  end
end
