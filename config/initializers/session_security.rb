# 세션 보안 설정

# 세션 쿠키 보안 설정
Rails.application.config.session_store :cookie_store, 
  key: '_monemusicpractice_session',
  expire_after: 30.minutes,  # 30분 후 자동 로그아웃
  secure: Rails.env.production?, # 프로덕션에서는 HTTPS만
  httponly: true, # JavaScript에서 접근 불가
  same_site: :lax # CSRF 공격 방지