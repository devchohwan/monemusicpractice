#!/bin/bash

# 앱 배포 스크립트
# EC2에서 초기 설정 후 실행

cd /var/www/monemusicpractice

echo "1. 의존성 설치..."
bundle install --without development test

echo "2. 프로덕션 secret key 생성..."
echo "RAILS_MASTER_KEY=$(rails secret)" >> .env
echo "SECRET_KEY_BASE=$(rails secret)" >> .env

echo "3. 데이터베이스 설정..."
RAILS_ENV=production rails db:create
RAILS_ENV=production rails db:migrate

echo "4. 프로덕션 assets 컴파일..."
RAILS_ENV=production rails assets:precompile

echo "5. 관리자 계정 생성..."
RAILS_ENV=production rails console << EOF
admin = User.new(
  username: 'admin',
  password: 'admin123!@#',
  name: '관리자',
  teacher: '무성',
  approved: true,
  is_admin: true
)
admin.save!
puts "관리자 계정 생성 완료: admin / admin123!@#"
EOF

echo ""
echo "=== 배포 완료 ==="
echo "다음 명령으로 서버 시작:"
echo "RAILS_ENV=production rails server -b 0.0.0.0 -p 3000"
echo ""
echo "프로덕션 환경에서는 Puma + Nginx를 권장합니다"