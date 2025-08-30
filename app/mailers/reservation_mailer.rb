class ReservationMailer < ApplicationMailer
  default from: "no-reply@example.com"

  def assigned
    @reservation = params[:reservation]
    @user = @reservation.user
    @table = @reservation.dining_table
    mail(to: @user.email, subject: "Rezervare alocată - Masa #{@table.name}")
  end
end

