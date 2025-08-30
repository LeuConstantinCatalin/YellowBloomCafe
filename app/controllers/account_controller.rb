class AccountController < ApplicationController
  def index
    @user = User.new
  end

  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      if user.respond_to?(:email_verified) && !user.email_verified
        session[:pending_user_id] = user.id
        send_verification_code(user)
        redirect_to verify_email_path, notice: "Cont neconfirmat. Am trimis un cod de verificare."
      else
        session[:user_id] = user.id
        redirect_to account_path, notice: "Autentificat cu succes"
      end
    else
      @user = User.new
      @error_message = "Email sau parola incorecte"
      render :index
    end
  end

  def update
    unless current_user
      redirect_to account_path, alert: "Trebuie sa fii autentificat." and return
    end

    if current_user.update(account_update_params)
      redirect_to account_path, notice: "Profil actualizat."
    else
      @user = User.new
      @update_errors = current_user.errors.full_messages
      render :index, status: :unprocessable_entity
    end
  end

  def logout
    reset_session
    redirect_to account_path, notice: "Delogat cu succes"
  end

  def destroy
    unless current_user
      redirect_to account_path, alert: "Trebuie sa fii autentificat." and return
    end

    current_user.destroy!
    reset_session
    redirect_to root_path, notice: "Contul a fost sters."
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

  def account_update_params
    params.require(:user).permit(:username, :nume, :prenume, :data_nastere, :adresa)
  end
end


