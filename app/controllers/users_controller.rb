class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.tip = "client"

    if @user.save
      flash[:notice] = "User created successfully"
      redirect_to root_path
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :nume, :prenume, :data_nastere, :email, :password, :password_confirmation)
  end
end
