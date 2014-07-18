require 'will_paginate/array'
require 'nokogiri'
require 'daitss'


include Daitss
include Datyl

class WorkspaceController < ApplicationController
  helper WorkspaceHelper
  before_filter :load_vars
  
  #initialize variable only once, skip initialization for ajax request also.
  def load_vars
    unless request.xhr? # unless there is an ajax request
      @projects = []
    end
  end
  
  def workspace
    @wips = archive.workspace.to_a
    @bins = archive.stashspace
    @action = '/workspace'

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
  
  def update
    #task = params.require('task')
    render :nothing => true
  end
  
  def workspaces
    ws = archive.workspace
    task = params.require('task')

    case params['task']
    when 'start'
      note = params.require(:note)
      
      if params['filter'] == 'true'
        startable = params['wips'].map {|w| Wip.new(File.join(ws.path, w))}
        startable = startable.reject { |w| w.running? or w.snafu? }
      else
        startable = ws.reject { |w| w.running? or w.snafu? }
      end
      
      startable.each do |w|
        w.unstop if w.stopped?
        w.reset_process if w.dead?
        w.spawn note, @user
      end
      
    when 'stop'
      note = params.require(:note)
      if params['filter'] == 'true'
        wip_list = params['wips'].map {|w| Wip.new(File.join(ws.path, w))}
        wip_list.select(&:running?).each { |w| w.stop note }
      else
        ws.select(&:running?).each { |w| w.stop note, @user }
      end
      
    when 'unsnafu'
      note = params.require(:note)
      
      # reset/unsnafu the snafued or dead wip
      if params['filter'] == 'true'
        wip_list = params['wips'].map {|w| Wip.new(File.join(ws.path, w))}
        wip_list.select(&:snafu?).each { |w| w.unsnafu note }
        wip_list.select(&:dead?).each { |w| w.unsnafu note }      
      else
        ws.select(&:snafu?).each { |w| w.unsnafu note, @user }
        ws.select(&:dead?).each { |w| w.unsnafu note, @user }      
      end
      
    when 'doover'
      note = params.require(:note)
      
      if params['filter'] == 'true'
        wip_list = params['wips'].map {|w| Wip.new(File.join(ws.path, w))}
        wip_list.each { |w| w.do_over note, @user }
      else
        ws.each { |w| w.do_over note, @user }
      end
      
    when 'stash'
      params.require('stash-bin')
      #error 400, 'parameter stash-bin is required' unless params['stash-bin']
      note = params.require(:note)
      bin = archive.stashspace.find { |b| b.name == params['stash-bin'] }
      unless bin
        #error 400, "bin #{bin} does not exist" unless bin
        #redirect_to '/500'
        return
      end
      
      if params['filter'] == 'true'
        stashable = params['wips'].map {|w| Wip.new(File.join(ws.path, w))}
        stashable = stashable.reject { |w| w.running? }
      else
        stashable = ws.reject { |w| w.running? }
      end
   
      stashable.each { |w| ws.stash w.id, bin, note, @user }
   
    when nil, ''
      #flash[:error] = "parameter task is required"
      #redirect_to '/500'
      return
    else
      #flash[:error] = "unknown command: #{params['task']}"
      #redirect_to '/500'
      return
    end
   
    #render 'work_space'
    #redirect_to :back
  end
  
  def show
    id = params[:id]
    @bins = archive.stashspace
    @wip = archive.workspace[id]
    @action = "/workspace/#{@wip.id}"
    
    out, err = @wip.std_data
    out = "no output data" unless out
    err = "no error data" unless err
    
  end

end
