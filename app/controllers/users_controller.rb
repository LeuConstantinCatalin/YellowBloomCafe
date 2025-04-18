class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.tip = "client"  # Presupunând că "tip" este un câmp de tip string sau similar

    if @user.save
      flash[:notice] = "User created successfully"  # Mesajul de succes
      redirect_to root_path  # Redirecționează la homepage, folosind root_path
    else
      render :new  # Răspunde cu formularul de înregistrare, dacă există erori
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :nume, :prenume, :data_nastere, :email, :password, :password_confirmation)
  end
end
