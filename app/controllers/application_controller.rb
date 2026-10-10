class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization
  add_flash_types :danger
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # juste avant de rendre la vue, il vérifie si on a acces à cette page sauf l'index et skip pundit uniquement dans les cas où
  # on se trouve dans un controller de devise ou les pages du controller pages et les pages d'administration
  after_action :verify_authorized, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  def after_sign_in_path_for(resource)
    resource.respond_to?(:admin?) && resource.admin? ? admin_path : root_path
  end

  private

  def user_not_authorized
    flash[:notice] = "Vous n'êtes pas autorisé à effectuer cette action."
    redirect_to root_path
  end

  def skip_pundit?
    devise_controller? || controller_name == "pages" ||
      controller_path.start_with?("rails/") ||
      controller_path.start_with?("admin/")
  end
end
