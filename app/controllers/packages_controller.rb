class PackagesController < ApplicationController
  helper_method :sort_column, :sort_direction  # make them available to application helpers 
  def index
   # @packages = Package.paginate(page: params[:page])
   #unless params[:sort].nil?
     sort = DataMapper::Query::Operator.new(sort_column, sort_direction)
     @packages= Package.search(params[:search]).all(:order => [sort]).paginate(page: params[:page])
  # else
  #   @packages = Package.paginate(page: params[:page])
  # end
  end
  
  private
  def sort_column  
    params[:sort] || "id"  
  end  
    
  def sort_direction  
    params[:direction] || "asc"  
  end    
end
