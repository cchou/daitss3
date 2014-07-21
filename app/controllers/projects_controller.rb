class ProjectsController < ApplicationController
  # GET /projects
  before_filter :authenticate_admin

  def index
    @projects = Project.user_projects
  end
    
  def new
    @project = Project.new
  end
  
  # create a new project model with the information entered.
  def create
    @project = Project.new(params[:project])
      
    if @project.save
      flash[:success] = "Project created"      
      redirect_to projects_url
    else
      flash[:danger] = "Cannot create project"
      render 'new'
    end
  end
 
  def edit
    @project = Project.get(params[:id], params[:account_id])
  end  

  # update project
  def update   
    @project = Project.get(params[:id], params[:account_id])
    begin
      @project.update(params[:project])
      flash[:success] = "Project updated"
      redirect_to projects_url  
    rescue => e
      flash[:danger] = "Cannot update project, other packages still reference it"
      redirect_to projects_url        
    end
  end  

  def destroy
    if (Project.get(params[:id], params[:account_id]).destroy)
      flash[:success] = "Project destroyed."
      redirect_to projects_url
    else
      flash[:danger] = "Cannot delete project, other packages still reference it"
      redirect_to projects_url      
    end
  end
      
end
