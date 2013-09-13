class PackagesController < ApplicationController
  helper_method :sort_column, :sort_direction  # make these two methods available to application helpers 
  
  def index
    # @packages = Package.paginate(page: params[:page])
    sort = DataMapper::Query::Operator.new(sort_column, sort_direction)
    @packages= Package.search(params[:search]).all(:order => [sort]).paginate(page: params[:page])
    @projects = []
  end
     
  # upload a package 
  def upload
    # the actual file that was posted, a StringIO
    file = request.env['rack.input'] rescue nil
    # the name of the file passed in the HTTP header
    filename = request.env['HTTP_X_FILENAME']  
    # save the uploaded file into the tmp directory
    data = file.read
    dir = Dir.mktmpdir
    path = File.join dir, filename
    open(path, 'wb') { |io| io.write data }
    puts "uploaded to #{path} "
    # HTTP 200, with empty response_body
    render :nothing => true
  end
 
  def submit
  end
   
  def show
    debugger
  end 
  
  # retrieve the list of projects associated with the selected account
  def select_account
    debugger
    # updates projects  based on the account selected
    projects = Project.all(:account_id => params[:account_id])
    # map to id for use in options_for_select
    @projects = projects.map{|a| a.id}
  end
    
  private
  def sort_column  
    params[:sort] || "id"  
  end  
    
  def sort_direction  
    params[:direction] || "asc"  
  end    

end
