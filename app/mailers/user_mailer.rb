class UserMailer < ApplicationMailer
  default from: "no-reply@example.com"

  def email_verification
    @user = params[:user]
    @code = params[:code]
    mail(to: @user.email, subject: "Cod de verificare email")
  end
end

