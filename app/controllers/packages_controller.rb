class PackagesController < ApplicationController
  helper_method :sort_column, :sort_direction  # make these two methods available to application helpers 
  
  def index
   # @packages = Package.paginate(page: params[:page])
   sort = DataMapper::Query::Operator.new(sort_column, sort_direction)
   @packages= Package.search(params[:search]).all(:order => [sort]).paginate(page: params[:page])
  end
  
  private
  def sort_column  
    params[:sort] || "id"  
  end  
    
  def sort_direction  
    params[:direction] || "asc"  
  end    

  def submit
  end
end
