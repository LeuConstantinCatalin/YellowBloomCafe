class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.tip = "client"

    if @user.save
      # Begin email verification flow
      session[:pending_user_id] = @user.id
      send_verification_code(@user)
      redirect_to verify_email_path, notice: "Cont creat! Ți-am trimis un cod de verificare."
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :nume, :prenume, :data_nastere, :email, :password, :password_confirmation)
  end

  private

  def generate_code
    "%06d" % SecureRandom.random_number(1_000_000)
  end

  def send_verification_code(user)
    code = generate_code
    user.update!(email_verification_code: code, email_verification_sent_at: Time.current, email_verified: false)
    UserMailer.with(user: user, code: code).email_verification.deliver_now
  end
end
