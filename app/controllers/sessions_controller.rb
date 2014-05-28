class SessionsController < ApplicationController
  def new
  end

  def create
    user = Agent.get(params[:id])
    if user && user.authenticate(params[:auth_key])
      # Sign the user in and redirect to package submission page.
      sign_in user
      # redirect_to user
      redirect_back_or submit_path
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url  
  end
end
