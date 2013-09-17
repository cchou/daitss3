class PackagesController < ApplicationController
  helper_method :sort_column, :sort_direction  # make these two methods available to application helpers 

  def index
    # debugger
    # @packages = Package.paginate(page: params[:page])
    # http://stackoverflow.com/questions/12429429/datamapper-sorting-results-through-association
    # if (params[:sort] == "account")
 
    # elsif (params[:sort] == "project")
  
    # else
      sort = DataMapper::Query::Operator.new(sort_column, sort_direction)
      @packages= Package.search(params[:id_search]).all(:order => [sort]).paginate(page: params[:page])
    # end
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
    flash[:success] = "uploaded to #{path}"
    # return HTTP 200, with empty response_body
    render :nothing => true
  end

  def submit
  end

  def show
  end 

  # retrieve the list of projects associated with the selected account
  def select_package_account
    # updates projects  based on the account selected
    projects = Project.all(:account_id => params[:account_id])
    # map to id for use in options_for_select
    @projects = projects.map{|a| a.id}
  end

  private
  def sort_column  
    params[:sort] || "id"  
    #Package.fields.include?(params[:sort]) ? params[:sort] : "id"
  end  

  def sort_direction  
    # params[:direction] || "asc"  
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end    

end
