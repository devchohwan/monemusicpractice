class PasswordResetController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:username])
    
    if user.nil?
      flash[:alert] = '가입되지 않은 회원입니다.'
      redirect_to password_reset_path
    else
      # 담당 선생님과 이름 확인
      if user.name == params[:name] && user.teacher == params[:teacher]
        # 안전한 토큰을 DB에 저장
        token = SecureRandom.urlsafe_base64(32)
        user.update(
          password_reset_token: Digest::SHA256.hexdigest(token),
          password_reset_sent_at: Time.current
        )
        
        # URL에 토큰 포함하여 리디렉션
        redirect_to edit_password_reset_path(token: token)
      else
        flash[:alert] = '정보가 일치하지 않습니다.'
        redirect_to password_reset_path
      end
    end
  end
  
  def edit
    # 토큰 확인
    @user = find_user_by_token(params[:token])
    if @user.nil?
      flash[:alert] = '유효하지 않거나 만료된 요청입니다. 다시 시도해주세요.'
      redirect_to password_reset_path
    end
  end
  
  def update
    # 토큰으로 사용자 찾기
    user = find_user_by_token(params[:token])
    
    if user.nil?
      flash[:alert] = '사용자를 찾을 수 없습니다.'
      redirect_to password_reset_path
    elsif params[:password].blank?
      flash[:alert] = '새 비밀번호를 입력해주세요.'
      redirect_to edit_password_reset_path(token: params[:token])
    elsif params[:password].length < 6
      flash[:alert] = '비밀번호는 최소 6자 이상이어야 합니다.'
      redirect_to edit_password_reset_path(token: params[:token])
    elsif params[:password] != params[:password_confirmation]
      flash[:alert] = '비밀번호가 일치하지 않습니다.'
      redirect_to edit_password_reset_path(token: params[:token])
    else
      # 새 비밀번호로 업데이트
      if user.update(password: params[:password])
        # 토큰 클리어
        user.update(password_reset_token: nil, password_reset_sent_at: nil)
        
        flash[:notice] = '비밀번호가 변경되었습니다. 새 비밀번호로 로그인해주세요.'
        redirect_to new_user_session_path
      else
        flash[:alert] = '비밀번호 재설정에 실패했습니다.'
        redirect_to edit_password_reset_path(token: params[:token])
      end
    end
  end
  
  private
  
  def find_user_by_token(token)
    return nil if token.blank?
    
    # 토큰을 해시화하여 DB에서 검색
    hashed_token = Digest::SHA256.hexdigest(token)
    user = User.find_by(password_reset_token: hashed_token)
    
    # 토큰이 10분 이내에 생성되었는지 확인
    if user && user.password_reset_sent_at > 10.minutes.ago
      user
    else
      nil
    end
  end
end