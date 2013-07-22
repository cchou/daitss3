class MainController < ApplicationController
  def home
  end
  
  def help
  end
  
  def admin
    @accounts = Account.user_accounts
    @projects = []
    @users = []
    
    respond_to do |format|
      format.html # admin.html.erb
      format.json { render json: @accounts }
    end  
  end  

  def select_account
    # updates projects  based on the account selected
    projects = Project.all(:account_id => params[:account_id])
    # map to id for use in options_for_select
    @projects = projects.map{|a| a.id}
    # updates users  based on the account selected
    users = User.all(:account_id => params[:account_id])
    # map to id for use in options_for_select
    @users = users.map{|a| a.id}    
  end
end
