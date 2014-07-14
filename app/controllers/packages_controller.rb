require 'will_paginate/array'
require 'nokogiri'
require 'daitss'
require 'debugger'

include Daitss
include Datyl

# Map Packages View column title to the Database table column name
Title_To_Column_Name = {
  "account" => "account_id",
  "project" => "project_id",
  "IEID" => "id",
  "Package Name" => "name",
  "Size" => "size_in_bytes",
  "# Files" => "number_of_datafiles",
  "Latest Activity" => "event_name",
  "Timestamp" => "timestamp"
}

SQL = "select t1.*
        from (
        SELECT p.id, s.name, pj.account_id, pj.id as project_id, s.size_in_bytes, s.number_of_datafiles, e.name as event_name, e.timestamp
          ,rank() over (partition by p.id order by e.timestamp) myrank
        from packages as p inner join sips as s on (p.id = s.package_id)
          inner join projects as pj on (p.project_account_id = pj.account_id and p.project_id = pj.id)
          inner join events as e on (p.id = e.package_id)
        where search_clause
        ) t1
        where t1.myrank=1
        order by order_by"
        
class PackagesController < ApplicationController
  helper_method :sort_column, :sort_direction  # make these two methods available to application helpers 
  before_filter :load_vars
  
  #initialize variable only once, skip initialization for ajax request also.
  def load_vars
    unless request.xhr? # unless there is an ajax request
      @projects = []
    end
  end
  
  # the order-by clause through associations doesn't quite work with datamapper and postgres,
  # so use direct sql instead.
  def index
    # convert the sorting title to the corresponding database column name
    column_name = Title_To_Column_Name[params[:sort]]
    # default to order by event timestamp
    column_name = "timestamp" if column_name.nil?
    # determine the order by clause
    order_by = column_name + " " + sort_direction
                 
    # determine the search clause based on the search param
    if (params[:id_search] && !params[:id_search].empty?)
      #TODO sanitize the search param since we are now using direct sql.
      search_clause = "p.id like '#{params[:id_search]}' or s.name like '#{params[:id_search]}'"      
      sql = SQL.gsub("search_clause", search_clause)
      sql = sql.gsub("order_by", order_by)              
    else
      names = 
        case params[:activity_search]
        when 'submitted'
          "('submit')"
        when 'rejected'
          "('reject','daitss v.1 reject')" 
        when 'archived'
          "('ingest finished')"
        when 'disseminated'
          "('disseminate finished')"
        when 'error'
          "('ingest snafu', 'disseminate snafu', 'refresh snafus')"
        when 'withdrawn'
          "('withdraw finished')"
        else
          "('submit', 'reject', 'ingest finished', 'disseminate finished', 'ingest snafu', 'disseminate snafu', 'withdraw finished', 'daitss v.1 provenance')"
        end
      # filter on date range
      @start_date  = if params[:start_time_search] and !params[:start_time_search].strip.empty?
          DateTime.strptime(params[:start_time_search], "%Y-%m-%d")
        else
          Time.at 0
        end

      @end_date = if params[:end_time_search] and !params[:end_time_search].strip.empty?
        DateTime.strptime(params[:end_time_search], "%Y-%m-%d")
      else
        DateTime.now
      end

      @end_date += 1
      # lookup account if passed in
        if (params[:account] && params[:account]["account_id"] && !params[:account]["account_id"].empty?)
          account = params[:account]["account_id"]
        end
        
        # lookup project if passed in
        if (params[:project] && params[:project] ["project_id"] && !params[:project]["project_id"].empty?)
          # account and project specified
          project = params[:project]["project_id"] if account
        end
        
        if account
          if project
            # account and project specified
            search_clause = "pj.account_id = '#{account}' and pj.id = '#{project}' and "
          else
            # account but not project specified
            search_clause = "pj.account_id = '#{account}' and "
          end
        else 
          # neither account nor project specified
          search_clause = ""        
      end
      search_clause += "e.timestamp between '#{@start_date}' and '#{@end_date}' and e.name in #{names}"      
      sql = SQL.gsub("search_clause", search_clause)
      sql = sql.gsub("order_by", order_by)                        
    end
    @results = DataMapper.repository(:default).adapter.select(sql).paginate(page: params[:page])
  end
  
  # TO BE REMOVED, search and order through datamapper, for historical purpose.
  def index_dm
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
    #debugger
    begin  
      batch_id = params["batch_id"]#.strip == "batch name" ? nil : params["batch_id"].strip
      note = params["note"] #== "note" ? nil : params["note"].strip
      
      p = archive.submit path, current_user, note
      
      if batch_id
        b = Batch.first_or_create(:id => batch_id)
        b.packages << p
        b.save
      end
      
      #p
    rescue => e
      raise e
    ensure
      FileUtils.rm_r dir
    end
    
    # return HTTP 200, with empty response_body
    render :nothing => true
  end

  def show
    search_clause = "p.id = '#{params[:id]}'"      
    sql = SQL.gsub("search_clause", search_clause)
    sql = sql.gsub("order_by", "timestamp")  
    results = DataMapper.repository(:default).adapter.select(sql) 
    @results = results.first
    @package = Package.get(params[:id])  
  end
  
  
  def work_space
    @wips = archive.workspace.to_a
    @bins = archive.stashspace
    
    if params['filter'] == 'true'
      
      # filter wips by date range
      start_date = if params['start_date'] and !params['start_date'].strip.empty?
                     Time.strptime(params['start_date'], "%m/%d/%Y")
                   else
                     Time.at 0
                   end
    
      end_date = if params['end_date'] and !params['end_date'].strip.empty?
                   Time.strptime(params['end_date'], "%m/%d/%Y")
                 else
                   Time.now
                 end
  
      end_date += 1
      @wips = @wips.select {|w| File.ctime(w.path) >= start_date and File.ctime(w.path) <= end_date }
  
      # filter wips by batch
  
      batch = Batch.get(params['batch-scope'])
                           
      if batch
        package_ids = batch.packages.map(&:id).to_set
        @wips = @wips.select {|w| package_ids.include? w.id }
      end

      # filter wips by account
      account = Account.get(params['account-scope'])

      if account
        package_ids = account.projects.packages.all(:id => @wips.map(&:id)).map(&:id).to_set
        @wips = @wips.select {|w| package_ids.include? w.id }
      end

      # filter wips by project
      project_id, account_id = params['project-scope'].split("-")
      act = Account.get(account_id)
      project = act.projects.first(:id => project_id) if act

      if project
        package_ids = project.packages.all(:id => @wips.map(&:id)).map(&:id).to_set
        @wips = @wips.select {|w| package_ids.include? w.id }
      end

      # filter wips by status

      status = params["status-scope"]

      case status
        when "running"
          @wips = @wips.select {|w| w.running? == true }
        when "idle"
          @wips = @wips.select {|w| w.state == :idle }
        when "error"
          @wips = @wips.select {|w| w.snafu? == true }
        when "stopped"
          @wips = @wips.select {|w| w.stopped? == true }
        when "dead"
          @wips = @wips.select {|w| w.dead? == true }
      end
    end #end if params['filter']

    @wips.sort! do |a,b|
    wip_sort_order(a) <=> wip_sort_order(b)
    end
  end
  
  def wip_sort_order w
    if w.running? then 3
    elsif w.state == :idle then 5
    elsif w.snafu? then 1
    elsif w.stopped? then 2
    elsif w.dead? then 4
    else 0
    end
  end
  
  # submit request for the curent package
  def submit_request
    #TBD add a request to the database
    redirect_to show_package_path(:id => params[:id]) 
  end
  
  def submit
  end
  
  def withdraw
  end
  
  def disseminate
  end
  
  def refresh
  end

  # retrieve the list of projects associated with the selected account
  def select_package_account
    # updates projects  based on the account selected
    projects = Project.all(:account_id => params[:account_id])

    # map to id for use in options_for_select
    @projects = projects.map{|a| a.id}
  end

  # retrieve the column name to be sorted.
  private
  def sort_column  
    params[:sort] || "timestamp"
  end  

  # retrieve the sort direction for the current selected column
  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "desc"
  end

end
