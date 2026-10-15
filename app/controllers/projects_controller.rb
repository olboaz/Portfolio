class ProjectsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    authorize Project
    @projects = policy_scope(Project)
  end

  def show
    authorize @project
  end

  def new
    @project = Project.new
    authorize @project
  end

  def create
    @project = Project.new(project_params)
    authorize @project

    if @project.save
      redirect_to project_path(@project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project

    if @project.update(project_params)
      redirect_to project_path(@project)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project = Project.find(params[:id])
    authorize @project

    if @project.destroy
      redirect_to projects_path, notice: "Le projet a été supprimé."
    else
      redirect_to projects_path, alert: "Impossible de supprimer le projet."
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :name,
      :project_type,
      :description,
      :url,
      :project_photo,
      photos: []
    )
  end
end