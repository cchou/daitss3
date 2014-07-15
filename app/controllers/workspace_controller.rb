require 'will_paginate/array'
require 'nokogiri'
require 'daitss'
require 'debugger'

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

end
