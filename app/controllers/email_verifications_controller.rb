class EmailVerificationsController < ApplicationController
  def new
    @user = pending_user
    unless @user
      redirect_to account_path, alert: "Niciun cont în curs de verificare."
    end
  end

  def create
    @user = pending_user
    unless @user
      redirect_to account_path, alert: "Sesiune de verificare expirată." and return
    end

    code = params[:code].to_s.strip
    if valid_code?(@user, code)
      @user.update!(email_verified: true, email_verification_code: nil)
      session.delete(:pending_user_id)
      session[:user_id] = @user.id
      redirect_to account_path, notice: "Email verificat cu succes."
    else
      flash.now[:alert] = "Cod invalid sau expirat."
      render :new, status: :unprocessable_entity
    end
  end

  def resend
    @user = pending_user
    unless @user
      redirect_to account_path, alert: "Sesiune de verificare expirată." and return
    end

    send_verification_code(@user)
    redirect_to verify_email_path, notice: "Am retrimis codul de verificare."
  end

  private

  def pending_user
    User.find_by(id: session[:pending_user_id])
  end

  def valid_code?(user, code)
    return false if user.email_verification_code.blank?
    return false if user.email_verification_sent_at && user.email_verification_sent_at < 30.minutes.ago
    ActiveSupport::SecurityUtils.secure_compare(user.email_verification_code, code)
  end

  def generate_code
    "%06d" % SecureRandom.random_number(1_000_000)
  end

  def send_verification_code(user)
    code = generate_code
    user.update!(email_verification_code: code, email_verification_sent_at: Time.current)
    UserMailer.with(user: user, code: code).email_verification.deliver_now
  end
end
