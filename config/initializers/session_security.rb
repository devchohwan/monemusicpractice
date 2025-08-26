# 세션 보안 설정

# 세션 쿠키 보안 설정
Rails.application.config.session_store :cookie_store, 
  key: '_monemusicpractice_session',
  expire_after: 30.minutes,  # 30분 후 자동 로그아웃
  secure: false, # HTTP 사용 중이므로 false로 설정 (나중에 HTTPS 적용 시 true로 변경)
  httponly: true, # JavaScript에서 접근 불가
  same_site: :lax # CSRF 공격 방지