class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        # Set success alert message
        flash[:notice] = 'signup_success'
        redirect_to new_user_session_path and return
      end
    end
  end
  
  protected
  
  def after_sign_up_path_for(resource)
    if resource.approved?
      root_path
    else
      new_user_session_path
    end
  end
  
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end