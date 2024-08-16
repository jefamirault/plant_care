class ApplicationController < ActionController::Base

  private

  def authenticate
    redirect_to request&.referer || new_session_path, alert: 'You must be logged in order to do that.' unless user_signed_in?
  end

  def authorize_admin
    unless current_user&.admin?
      redirect_to request&.referer || root_path,
                  alert: "You must have admin permissions in order to do that."
    end
  end
  def authorize_viewer(project = current_project)
    unless authorized?(current_user, :viewer)
      redirect_to projects_path,
                  alert: "You do not have Viewer permissions for that project."
    end
  end
  def authorize_editor(project = current_project)
    unless authorized?(current_user, :editor)
      redirect_to request&.referer || plants_path,
                  alert: "You do not have Editor permissions for this project."
    end
  end
  def authorized?(user, role, project = current_project)
    if !user_signed_in?
      return false
    elsif project&.owner == user || user&.admin?
      return true
    elsif !user_signed_in?
      return false
    end
    c = Collaboration.where(user: user, project: project).first
    return false if c.nil?
    permission_level = Collaboration.roles[c.role]
    required_level = Collaboration.roles[role]
    permission_level >= required_level
  end

  def set_current_project(project)
    cookies.encrypted[:project_id] = { value: project.id, expires: 1.year }
    Current.project = project
  end
  def current_project
    Current.project ||= get_project_from_session
  end
  helper_method :current_project

  def current_user
    Current.user ||= authenticate_user_from_session
  end
  helper_method :current_user

  def authenticate_user_from_session
    User.find_by(id: cookies.encrypted[:user_id])
  end
  def get_project_from_session
    Project.find_by id: cookies.encrypted[:project_id]
  end

  def user_signed_in?
    current_user.present?
  end
  helper_method :user_signed_in?
  def login(user)
    Current.user = user
    reset_session
    cookies.encrypted[:user_id] = { value: user.id, expires: 6.months }
  end

  def logout
    Current.project = nil
    Current.user = nil
    reset_session
    cookies.delete :project_id
    cookies.delete :user_id
    redirect_to new_session_path, notice: "You have been logged out."
  end
end
