#!/bin/bash

# EC2 Ubuntu 서버 초기 설정 스크립트
# 이 스크립트를 EC2 인스턴스에서 실행하세요

echo "=== 모네뮤직 연습실 시스템 배포 스크립트 ==="

# 1. 시스템 업데이트
echo "1. 시스템 업데이트 중..."
sudo apt-get update
sudo apt-get upgrade -y

# 2. 필수 패키지 설치
echo "2. 필수 패키지 설치 중..."
sudo apt-get install -y git curl build-essential libssl-dev libreadline-dev zlib1g-dev \
                        libsqlite3-dev sqlite3 nodejs npm nginx

# 3. rbenv 설치 (Ruby 버전 관리)
echo "3. rbenv 설치 중..."
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 4. Ruby 3.3.6 설치
echo "4. Ruby 3.3.6 설치 중... (시간이 걸립니다)"
rbenv install 3.3.6
rbenv global 3.3.6

# 5. Bundler 설치
echo "5. Bundler 설치 중..."
gem install bundler

# 6. 프로젝트 클론
echo "6. 프로젝트를 /var/www 디렉토리에 클론하세요:"
echo "   sudo mkdir -p /var/www"
echo "   sudo chown $USER:$USER /var/www"
echo "   cd /var/www"
echo "   git clone [your-repo-url] monemusicpractice"

echo ""
echo "=== 설정 완료 ==="
echo "다음 단계:"
echo "1. 프로젝트를 GitHub에 푸시하세요"
echo "2. EC2에서 프로젝트를 클론하세요"
echo "3. deploy_app.sh 스크립트를 실행하세요"