class MainController < ApplicationController
  def dashboard
  end
  
  def help
  end
  
  # administer users, accounts and projects
  def admin
    @accounts = Account.user_accounts
    @projects = []
    @users = []
    
    respond_to do |format|
      format.html # admin.html.erb
      format.json { render json: @accounts }
    end  
  end

  # when a user select an account, retrieve all associated projects and users to that account
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

  # FDA log message
  def log
    @entries = Entry.all
  end

  #create a new log message
  def log_message
    e = Entry.new
    e.message = params[:message]
    e.operator = current_user
    e.save or error "could not save archive log entry"  
    redirect_to log_path
  end    
end
