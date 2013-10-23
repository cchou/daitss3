class ProjectsController < ApplicationController
  # GET /projects

  def index
    @projects = Project.all - Project.all(:account_id => "SYSTEM")
  end
    
  def new
    @project = Project.new
  end
  
  # create a new project model with the information entered.
  def create
    @project = Project.new(params[:project])
      
    if @project.save
      redirect_to projects_url
    end
  end
 
  def edit
    @project = Project.get(params[:id], params[:account_id])
  end  

  # update project
  def update
    @project = Project.get(params[:id], params[:account_id])
    if @project.update(params[:project])
      flash[:success] = "Project updated"
      redirect_to projects_url
    else
      render 'edit'
    end
  end  

  def destroy
    if (Project.get(params[:id], params[:account_id]).destroy)
      flash[:success] = "Project destroyed."
      redirect_to projects_url
    else
      flash[:error] = "Cannot delete project, other packages still reference it"
      redirect_to projects_url      
    end
  end
      
end
