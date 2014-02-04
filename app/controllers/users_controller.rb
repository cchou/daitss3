class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy] #only signed in user can edit/update/list
  before_filter :correct_user,   only: [:edit, :update] # make sure an user can only edit his/her own information
  
  def index
    # @users = User.all
    @users = User.paginate(page: params[:page])
  end
  
  # retrieve the information for the selected user (agent)
  def show
    @user = User.get(params[:id])    
  end
  
  def new
    @user = User.new
  end
  
  # create a new user model with the information entered.
  def create
    @user = User.new(params[:user])
    @user.encrypt_auth(@user.auth_key)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Florida Digital Archive!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.get(params[:id])
  end  

  # update user profile
  def update
    @user = User.get(params[:id])
    #    if @user.authenticate(params[:user][:auth_key]) && @user.update(params[:user])
    if @user.update(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end  

  # update user profile by an administrator
  def admin_update
    @user = User.get(params[:id])
    if @user.update(params[:user])
      flash[:success] = "User updated"
    else
      render 'edit'
    end
  end  
  
  def destroy
    User.get(params[:id]).destroy!
    flash[:success] = "User destroyed."
    redirect_to users_url
  end
  
  private
    # sign in the user, and store their original url location.
    def signed_in_user
      store_location
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end  

    def correct_user
      @user = User.get(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end  
end
