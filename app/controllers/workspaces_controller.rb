class WorkspacesController < ApplicationController
  before_action :set_workspace, only: [ :show, :update, :destroy, :edit ]

  def index
    @workspaces = Workspace.all
  end

  def show
  end

  def new
    @workspace = Workspace.new
  end

  def create
    @workspace = Workspace.new(workspace_params)
    respond_to do |format|
      if @workspace.save
        format.html {
          redirect_to @workspace,
          notice: "#{@workspace.name} Workspace created successfully"
        }
      else
        format.html {
          render :new,
          status: :unprocessable_entity
        }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @workspace.update(workspace_params)
        format.html {
          redirect_to @workspace,
                      notice: "#{@workspace.name} Workspace updated successfully"
        }
      else
        format.html {
          render :edit,
                 status: :unprocessable_entity
        }
      end
    end
  end


  def destroy
    @workspace.destroy
    respond_to do |format|
      format.html { redirect_to workspaces_path, notice: "#{@workspace.name} was successfully destroyed." }
    end
  end

  private
    def set_workspace
      @workspace = Workspace.find(params[:id])
    end

    def workspace_params
      params.require(:workspace).permit(:name)
    end
end
