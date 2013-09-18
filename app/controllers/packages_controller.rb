class PackagesController < ApplicationController
  helper_method :sort_column, :sort_direction  # make these two methods available to application helpers 
  
  def index
    # debugger
    # @packages = Package.paginate(page: params[:page])
    # http://stackoverflow.com/questions/12429429/datamapper-sorting-results-through-association
    # if (params[:sort] == "account")
    # elsif (params[:sort] == "project")
    # else
    unless (params[:id_search].empty?)
      sort = DataMapper::Query::Operator.new(sort_column, sort_direction)
      @packages= Package.search(params[:id_search]).all(:order => [sort]).paginate(page: params[:page])
    else
      # filter on activity
      names = 
        case params[:activity_search]
        when 'submitted'
          "submit"
        when 'rejected'
          ["reject","daitss v.1 reject"] 
        when 'archived'
          "ingest finished"
        when 'disseminated'
          "disseminate finished"
        when 'error'
          ["ingest snafu", "disseminate snafu", "refresh snafus"]
        when 'withdrawn'
          "withdraw finished"
        else
          ['submit', "reject", "ingest finished", "disseminate finished", "ingest snafu", "disseminate snafu", "withdraw finished", "daitss v.1 provenance"]
        end

      # filter on date range
      start_date  = if params[:start_time_search] and !params[:start_time_search].strip.empty?
          DateTime.strptime(params[:start_time_search], "%Y-%m-%dT%H:%M")
        else
          Time.at 0
        end

      end_date = if params[:end_time_search] and !params[:end_time_search].strip.empty?
        DateTime.strptime(params[:end_time_search], "%Y-%m-%dT%H:%M")
      else
        DateTime.now
      end

      end_date += 1
      range = (start_date..end_date)

      # lookup account if passed in
      if (params[:account] && params[:account]["account_id"])
        account = Account.get(params[:account]["account_id"])
      end
      
      # lookup project if passed in
      if params[:project] && params[:project] ["project_id"]
        # account and project specified
        project = account.projects.first(:id => params[:project]["project_id"]) if account
      end
      
      if account 
        if (project)
          # account and project specified
          ps = project.packages.events.all(:timestamp => range, :name => names, :order => [ :timestamp.desc ]).packages 
        else
          # account but not project specified
          ps = account.projects.packages.events.all(:timestamp => range, :name => names, :order => [ :timestamp.desc ] ).packages 
        end
      else 
        # neither account nor project specified
        ps = Event.all(:timestamp => range, :name => names, :order => [ :timestamp.desc ]).packages 
      end

      # filter on batches
      batch = Batch.get(params[:batch_search])
      if batch       
        ps = ps.find_all { |p| p.batches.include? batch } 
      end
      @packages = ps.paginate(page: params[:page])
    end
    
    @projects = []
  end
  
  # upload a package 
  def upload
    # the actual file that was sent via HTTP post, a StringIO
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
