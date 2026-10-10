
class AdminController < ApplicationController
  before_action :require_admin!

  # Le tableau de bord n'utilise pas de modèle Pundit.
  skip_after_action :verify_authorized, only: :index
  skip_after_action :verify_policy_scoped, only: :index

  def index
    @projects_count = Project.count
    @tools_count = Tool.count

    @recent_projects = Project.order(created_at: :desc).limit(5)
    @recent_tools = Tool.order(created_at: :desc).limit(5)
  end

  private

  def require_admin!
    unless current_user&.admin?
      raise Pundit::NotAuthorizedError
    end
  end
end
