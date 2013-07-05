class UsersController < ApplicationController
  def show
    @user = Agent.get(params[:id])    
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    debugger
    @user.encrypt_auth(@user.auth_key)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Florida Digital Archive!"
      redirect_to @user
    else
      render 'new'
    end
  end
end
