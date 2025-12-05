class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  protected

  # Devise redirects
  def after_sign_in_path_for(resource)
    workspaces_path
  end

  def after_sign_up_path_for(resource)
    workspaces_path
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  # Authorization helpers
  def authorize_resource!(condition, message:, redirect_to:)
    return if condition

    respond_to do |format|
      format.html { redirect_to redirect_to, alert: message }
      format.json { render json: { error: message }, status: :forbidden }
    end
  end

  def authorize_owner!(workspace)
    authorize_resource!(
      current_user == workspace.owner,
      message: "You are not authorized to perform this action.",
      redirect_to: workspace_path(workspace)
    )
  end

  def authorize_admin!(workspace)
    authorize_resource!(
      workspace.role_owner?(current_user) || workspace.role_admin?(current_user),
      message: "You are not authorized to manage workspace members.",
      redirect_to: workspace_path(workspace)
    )
  end

  # Resource finders with error handling
  def find_resource(model, id, error_message: nil, redirect_path: nil)
    return nil if id.nil?

    model.find(id)
  rescue ActiveRecord::RecordNotFound
    error_message ||= "#{model.name} not found."
    redirect_path ||= root_path

    respond_to do |format|
      format.html { redirect_to redirect_path, alert: error_message }
      format.json { render json: { error: error_message }, status: :not_found }
    end
    nil
  end

  private

  # Global error handlers
  def record_not_found(exception)
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Resource not found." }
      format.json { render json: { error: "Resource not found" }, status: :not_found }
    end
  end

  def parameter_missing(exception)
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Required parameter is missing." }
      format.json { render json: { error: exception.message }, status: :bad_request }
    end
  end

  def record_invalid(exception)
    respond_to do |format|
      format.html { redirect_to root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :unprocessable_entity }
    end
  end

  # Success/Error response helpers
  def respond_with_success(path, notice:, format: :html)
    respond_to do |f|
      case format
      when :html
        f.html { redirect_to path, notice: notice }
      when :json
        f.json { render json: { message: notice }, status: :ok }
      end
    end
  end

  def respond_with_error(path, alert:, status: :unprocessable_entity)
    respond_to do |format|
      format.html { redirect_to path, alert: alert }
      format.json { render json: { error: alert }, status: status }
    end
  end

  def render_form_errors(template, resource, status: :unprocessable_entity)
    respond_to do |format|
      format.html { render template, status: status, locals: { resource: resource } }
      format.json { render json: { errors: resource.errors.full_messages }, status: status }
    end
  end
end