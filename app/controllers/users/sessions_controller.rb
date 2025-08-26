# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :html, :turbo_stream
  
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    # First try to find the user
    user = User.find_by(username: params[:user][:username])
    
    if user.nil?
      # User doesn't exist
      flash[:alert] = 'no_user'
      redirect_to new_user_session_path
    elsif !user.approved?
      # User exists but not approved
      flash[:alert] = 'not_approved'
      redirect_to new_user_session_path
    elsif !user.valid_password?(params[:user][:password])
      # Password is incorrect
      flash[:alert] = 'wrong_password'
      redirect_to new_user_session_path
    else
      # Try to authenticate
      self.resource = warden.authenticate!(auth_options)
      if resource
        set_flash_message!(:notice, :signed_in)
        sign_in(resource_name, resource)
        flash.clear
        yield resource if block_given?
        respond_with resource, location: after_sign_in_path_for(resource)
      end
    end
  rescue StandardError
    # Other errors
    flash[:alert] = 'invalid'
    redirect_to new_user_session_path
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  
  private

  def respond_to_on_destroy
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name), status: :see_other }
    end
  end
end
