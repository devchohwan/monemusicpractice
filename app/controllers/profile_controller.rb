class ProfileController < ApplicationController
  before_action :authenticate_user!
  
  def edit
  end

  def update_password
    if params[:current_password].blank?
      flash[:alert] = '현재 비밀번호를 입력해주세요.'
      redirect_to edit_profile_path
    elsif !current_user.valid_password?(params[:current_password])
      flash[:alert] = '현재 비밀번호가 올바르지 않습니다.'
      redirect_to edit_profile_path
    elsif params[:password].blank?
      flash[:alert] = '새 비밀번호를 입력해주세요.'
      redirect_to edit_profile_path
    elsif params[:password].length < 6
      flash[:alert] = '비밀번호는 최소 6자 이상이어야 합니다.'
      redirect_to edit_profile_path
    elsif params[:password] != params[:password_confirmation]
      flash[:alert] = '새 비밀번호가 일치하지 않습니다.'
      redirect_to edit_profile_path
    elsif params[:password] == params[:current_password]
      flash[:alert] = '새 비밀번호는 현재 비밀번호와 달라야 합니다.'
      redirect_to edit_profile_path
    else
      if current_user.update(password: params[:password])
        # Devise로 다시 로그인
        bypass_sign_in(current_user)
        flash[:notice] = '비밀번호가 성공적으로 변경되었습니다.'
        redirect_to root_path
      else
        flash[:alert] = '비밀번호 변경에 실패했습니다.'
        redirect_to edit_profile_path
      end
    end
  end
end