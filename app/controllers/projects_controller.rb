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

    attributes = project_params
    new_photos = Array(attributes.delete(:photos)).reject(&:blank?)
    remove_photo_ids = Array(attributes.delete(:remove_photo_ids)).reject(&:blank?)

    existing_attachments = @project.photos.attachments.to_a

    # Vérifier que toutes les images à supprimer appartiennent au projet.
    valid_ids = existing_attachments.map { |photo| photo.id.to_s }

    if (remove_photo_ids - valid_ids).any?
      redirect_to edit_project_path(@project),
                  alert: "Une image sélectionnée est invalide."
      return
    end

    # Conserver les images non sélectionnées pour suppression.
    kept_attachments = existing_attachments.reject do |photo|
      remove_photo_ids.include?(photo.id.to_s)
    end

    # Vérifier le quota avant toute modification.
    if kept_attachments.size + new_photos.size > Project::MAX_ADDITIONAL_PHOTOS
      redirect_to edit_project_path(@project),
                  alert: "Impossible d'ajouter des images supplémentaires : " \
                        "la galerie est limitée à 4 images par projet."
      return
    end

    # Valider les autres champs avant de modifier les pièces jointes.
    @project.assign_attributes(attributes)

    if @project.valid?
      @project.photos = kept_attachments.map(&:blob) + new_photos

      if @project.save
        redirect_to project_path(@project),
                    notice: "Le projet a été mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
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
      photos: [],
      remove_photo_ids: []
    )
  end
end