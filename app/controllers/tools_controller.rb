class ToolsController < ApplicationController
  before_action :set_tool, only: [:show, :edit, :update, :destroy]

  def index
    authorize Tool
    @tools = policy_scope(Tool)
  end

  def show
    authorize @tool
  end

  def new
    @tool = Tool.new
    authorize @tool
  end

  def create
    @tool = Tool.new(tool_params)
    authorize @tool

    if @tool.save
      redirect_to tool_path(@tool)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @tool
  end

  def update
    authorize @tool

    if @tool.update(tool_params)
      redirect_to tool_path(@tool)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tool = Tool.find(params[:id])
    authorize @tool

    if @tool.destroy
      redirect_to tools_path, notice: "L'outil a été supprimé."
    else
      redirect_to tools_path, alert: "Impossible de supprimer l'outil."
    end
  end

  private

  def set_tool
    @tool = Tool.find(params[:id])
  end

  def tool_params
    params.require(:tool).permit(:name, :tool_type, :tool_photo)
  end
end