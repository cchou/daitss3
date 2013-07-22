class SessionsController < ApplicationController
  def new
  end

  def create
    user = Agent.get(params[:session][:id])
    if user && user.authenticate(params[:session][:auth_key])
      # Sign the user in and redirect to the user's show page.
      sign_in user
      #redirect_to user
      redirect_back_or user
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url  
  end
end
