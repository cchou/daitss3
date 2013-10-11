class PackagesController < ApplicationController
  helper_method :sort_column, :sort_direction  # make these two methods available to application helpers 
  before_filter :load_vars
  
  #initialize variable only once, skipped initialization for ajax request also.
  def load_vars
    unless request.xhr? # unless there is an ajax request
      @projects = []
    end
  end
  
  def index_sql
    # default to order by event timestamp
    order_by = "e.timestamp"
    
    # determine the order by clause
    if (params[:sort] == "account")
      order_by = "pj.account_id"
    elsif (params[:sort] == "project")
      order_by = "pj.id"
    elsif (params[:sort] == "IEID")
      order_by = "p.id"
    elsif (params[:sort] == "Package Name")
      order_by = "s.name"      
    elsif (params[:sort] == "Size")
      order_by = "s.size_in_bytes"
    elsif (params[:sort] == "# Files")
      order_by = "s.number_of_datafiles"
    elsif (params[:sort] == "Timestamp")
      order_by = "e.timestampe"
    end
                 
    if (params[:id_search] && !params[:id_search].empty?)
      search_clause = "p.id like #{param[:id_search]} or s.name like #{params[:id_search]}"                      
      sql = "SELECT p.id, s.name, pj.account_id, pj.id, s.size_in_bytes, s.number_of_datafiles, 
        e.timestamp from packages as p, sips as s, projects as pj, events as e 
        where #{search_clause} and p.id = e.package_id and p.id = s.package_id order by #{order_by}"
        # sort = DataMapper::Query::Operator.new(sort_column, sort_direction)
      @packages = Package.find_by_sql(sql)
    else
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
          ['submit', 'reject', 'ingest finished', "disseminate finished", "ingest snafu", "disseminate snafu", "withdraw finished", "daitss v.1 provenance"]
        end

      # filter on date range
      start_date  = if params[:start_time_search] and !params[:start_time_search].strip.empty?
          DateTime.strptime(params[:start_time_search], "%Y-%m-%d")
        else
          Time.at 0
        end

      end_date = if params[:end_time_search] and !params[:end_time_search].strip.empty?
        DateTime.strptime(params[:end_time_search], "%Y-%m-%d")
      else
        DateTime.now
      end

      end_date += 1
      range = (start_date..end_date)      
      search_clause = "e.timestamp between '#{start_date}' and '#{end_date}'"                      
      sql = "SELECT p.id, s.name, pj.account_id, pj.id, s.size_in_bytes, s.number_of_datafiles, 
        e.timestamp from packages as p, sips as s, projects as pj, events as e 
        where p.id = e.package_id and p.id = s.package_id order by #{order_by}"
      #@packages = Package.find_by_sql(sql)    
      @packages = DataMapper.repository(:default).adapter.select(sql)
    end
  end
  
  def index
    # http://stackoverflow.com/questions/12429429/datamapper-sorting-results-through-association
    #startime = Time.at 0
    #endtime = DateTime.now
    #range = (startime..endtime)
    # ps = Package.all(:order => [DataMapper::Query::Direction.new(Event.properties[:timestamp])], :links =>[:events])
    # @packages = ps.paginate(page: params[:page]) 
    # @packages= Package.all(Package.events.timestamp => range, :fields => [ Package.events.timestamp], :unique => true, :order => [ Package.events.timestamp.desc ]).paginate(page: params[:page])
    # @packages = Package.ordered_by_timestamp(:desc).all.paginate(page: params[:page]) 
    # @packages = Package.find_by_sql("SELECT p.id, e.timestamp from packages as p, events as e where p.id = e.package_id order by e.timestamp ")
    sort = DataMapper::Query::Operator.new(sort_column, sort_direction)
      if (params[:id_search] && !params[:id_search].empty?)
        #ps = Sip.all(:name.like => params[:id_search]).packages.events.all(:order => [sort]).packages | 
        ps = Package.all(:id.like => params[:id_search], :order => [sort])
        @packages = ps#.paginate(page: params[:page])
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
            DateTime.strptime(params[:start_time_search], "%Y-%m-%d")
          else
            Time.at 0
          end
      
        end_date = if params[:end_time_search] and !params[:end_time_search].strip.empty?
          DateTime.strptime(params[:end_time_search], "%Y-%m-%d")
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
    # TODO flash[:success] = "uploaded to #{path}"
    @message = "uploaded to #{path}"
    # return HTTP 200, with empty response_body
    render :nothing => true
  end

  def submit
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
