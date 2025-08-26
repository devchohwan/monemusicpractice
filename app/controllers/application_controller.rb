class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :name, :teacher])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :name, :teacher])
  end
  
  def authenticate_admin!
    authenticate_user!
    redirect_to root_path, alert: '권한이 없습니다.' unless current_user.is_admin?
  end
  
  # Devise 로그인 성공 후 호출
  def after_sign_in_path_for(resource)
    # 세션 ID 변경 (세션 고정 공격 방지)
    request.session_options[:renew] = true if request.session_options
    stored_location_for(resource) || root_path
  end
end