module SessionsHelper
  def sign_in(user)
    remember_token = user.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update(:remember_token => remember_token)
    self.current_user = user
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end
  
  def signed_in?
    puts "current user #{@current_user}"
    puts "cookies #{cookies[:remember_token]}"
    !current_user.nil?
  end
    
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||= User.first(:remember_token => cookies[:remember_token])
  end  

  def current_user?(user)
    user == current_user
  end
    
  def admin_user?
    current_user.is_admin_contact?
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end  
end
