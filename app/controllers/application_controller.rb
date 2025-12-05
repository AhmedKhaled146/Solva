class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  stale_when_importmap_changes
  protected

  def after_sign_in_path_for(resource)
    workspaces_path
  end

  def after_sign_up_path_for(resource)
    workspaces_path
  end

  def after_sign_out_path_for(resource)
    root_path
  end
end
