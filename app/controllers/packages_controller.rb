class PackagesController < ApplicationController
  def index
    @packages = Package.paginate(page: params[:page])
  end
end
