class AccountController < ApplicationController
  require 'json'

  def index
    @user = User.new
    file_path = Rails.root.join("storage", "users.json")

    if session[:user_email] && File.exist?(file_path)
      users = JSON.parse(File.read(file_path))
      @current_user = users.find { |u| u["email"] == session[:user_email] }
    end
  end

def create
  file_path = Rails.root.join("storage", "users.json")
  if File.exist?(file_path)
    users = JSON.parse(File.read(file_path))
    user = users.find { |u| u["email"] == params[:email] }
    
    if user && User.authenticate(params[:email], params[:password])
      session[:user_email] = user["email"]
      redirect_to account_path, notice: "Autentificat cu succes"
      return
    end
  end

  @user = User.new
  @error_message = "Email sau parolă incorecte"
  render :index
end

  def signup
    user_data = {
      username: params[:username],
      nume: params[:nume],
      prenume: params[:prenume],
      data_nastere: params[:data_nastere],
      email: params[:email],
      password: params[:password]
    }

    file_path = Rails.root.join("storage", "users.json")
    FileUtils.mkdir_p(File.dirname(file_path)) unless File.exist?(file_path)

    users = File.exist?(file_path) ? JSON.parse(File.read(file_path)) : []
    users << user_data
    File.write(file_path, JSON.pretty_generate(users))

    session[:user_email] = user_data[:email]
    redirect_to account_path, notice: "Cont creat cu succes!"
  end
end
