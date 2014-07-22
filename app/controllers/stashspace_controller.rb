require 'nokogiri'
require 'daitss'


include Daitss
include Datyl

class StashspaceController < ApplicationController
  helper StashspaceHelper
  before_filter :authenticate_admin, :load_vars
  
  #initialize variable only once, skip initialization for ajax request also.
  def load_vars
    unless request.xhr? # unless there is an ajax request
      @projects = []
    end
  end
  
  def stashspace
    @bins = archive.stashspace
    @action = '/stashspace'
  end
  
  def show
    
  end
  
  def create
    name = params.require('name')
    bin = StashBin.make! name
    archive.log "new stash bin: #{bin}", @user
    redirect_to "/stashspace"
  end
  
  def delete
    id = params[:id]
    id = URI.encode id # SMELL sinatra is decoding this
    bin = archive.stashspace.find { |b| b.id == id }
    bin.delete or error "cannot not delete stash bin"
    archive.log "delete stash bin: #{bin}", @user
    redirect_to "/stashspace"
  end
  
end
