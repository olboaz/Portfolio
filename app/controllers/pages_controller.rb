class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :privacy] # skip login for some pages

  def home
    @projects = Project.all
    @tools = Tool.all
    @contact = Contact.new
  end

  def privacy
  end

end
