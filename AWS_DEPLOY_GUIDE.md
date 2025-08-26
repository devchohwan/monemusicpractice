# AWS EC2 배포 가이드

## 🚀 배포 단계별 가이드

### 1단계: GitHub에 코드 푸시
```bash
cd /home/cho/monemusicpractice
git init
git add .
git commit -m "Initial commit - Mone Music Practice Room System"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/monemusicpractice.git
git push -u origin main
```

### 2단계: EC2 인스턴스 생성
1. AWS Console 접속
2. EC2 → Launch Instance
3. 설정:
   - **Name**: mone-music-practice
   - **OS**: Ubuntu Server 22.04 LTS
   - **Instance Type**: t2.micro (프리티어)
   - **Security Group**:
     - SSH (22)
     - HTTP (80)
     - HTTPS (443)
     - Custom TCP (3000) - 테스트용

### 3단계: EC2 접속
```bash
# 로컬에서
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@[EC2-PUBLIC-IP]
```

### 4단계: EC2 서버 설정
```bash
# EC2에서
wget https://raw.githubusercontent.com/YOUR_USERNAME/monemusicpractice/main/deploy_setup.sh
chmod +x deploy_setup.sh
./deploy_setup.sh
```

### 5단계: 프로젝트 클론 및 설정
```bash
# EC2에서
sudo mkdir -p /var/www
sudo chown ubuntu:ubuntu /var/www
cd /var/www
git clone https://github.com/YOUR_USERNAME/monemusicpractice.git
cd monemusicpractice

# 필요한 디렉토리 생성
mkdir -p shared/tmp/sockets
mkdir -p shared/tmp/pids
mkdir -p log
```

### 6단계: 앱 배포
```bash
# EC2에서
chmod +x deploy_app.sh
./deploy_app.sh
```

### 7단계: Nginx 설정
```bash
# EC2에서
sudo cp config/nginx.conf /etc/nginx/sites-available/monemusicpractice
sudo ln -s /etc/nginx/sites-available/monemusicpractice /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# nginx.conf 파일 수정 (EC2 Public IP로 변경)
sudo nano /etc/nginx/sites-available/monemusicpractice
# server_name 부분을 EC2 Public IP로 수정

sudo nginx -t
sudo systemctl restart nginx
```

### 8단계: Puma 서버 시작
```bash
# EC2에서
cd /var/www/monemusicpractice
RAILS_ENV=production bundle exec puma -C config/puma_production.rb
```

### 9단계: 서비스 등록 (자동 시작)
```bash
# systemd 서비스 파일 생성
sudo nano /etc/systemd/system/puma.service
```

다음 내용 입력:
```ini
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/var/www/monemusicpractice
Environment="RAILS_ENV=production"
ExecStart=/home/ubuntu/.rbenv/shims/bundle exec puma -C config/puma_production.rb
ExecStop=/home/ubuntu/.rbenv/shims/bundle exec pumactl -S /var/www/monemusicpractice/shared/tmp/pids/puma.state stop
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# 서비스 활성화 및 시작
sudo systemctl daemon-reload
sudo systemctl enable puma
sudo systemctl start puma
sudo systemctl status puma
```

## 📝 배포 후 확인사항

### 접속 테스트
1. 브라우저에서 `http://[EC2-PUBLIC-IP]` 접속
2. 관리자 로그인: `admin` / `admin123!@#`
3. 비밀번호 변경 권장

### 로그 확인
```bash
# Rails 로그
tail -f /var/www/monemusicpractice/log/production.log

# Nginx 로그
tail -f /var/www/monemusicpractice/log/nginx.access.log
tail -f /var/www/monemusicpractice/log/nginx.error.log

# Puma 로그
tail -f /var/www/monemusicpractice/log/puma.stdout.log
```

### 문제 해결
```bash
# Puma 재시작
sudo systemctl restart puma

# Nginx 재시작
sudo systemctl restart nginx

# 데이터베이스 초기화 (주의!)
cd /var/www/monemusicpractice
RAILS_ENV=production rails db:reset
```

## 🔒 보안 설정 (권장)

### 1. 방화벽 설정
```bash
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

### 2. SSL 인증서 (Let's Encrypt)
```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### 3. 환경변수 파일
```bash
# .env 파일 생성
nano /var/www/monemusicpractice/.env

# 내용:
RAILS_ENV=production
SECRET_KEY_BASE=[rails secret으로 생성한 값]
RAILS_MASTER_KEY=[rails secret으로 생성한 값]
```

## 📊 모니터링

### 서버 상태 확인
```bash
# CPU, 메모리 사용량
htop

# 디스크 사용량
df -h

# 프로세스 확인
ps aux | grep puma
ps aux | grep nginx
```

## 🔄 업데이트 방법

```bash
cd /var/www/monemusicpractice
git pull origin main
bundle install
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails assets:precompile
sudo systemctl restart puma
sudo systemctl restart nginx
```

## 💰 비용 관리

- **t2.micro**: 프리티어 750시간/월 무료
- **EBS Storage**: 30GB까지 무료
- **Data Transfer**: 15GB/월 무료

## 🚨 주의사항

1. **관리자 비밀번호 즉시 변경**
2. **정기적인 백업 설정**
3. **CloudWatch 모니터링 설정**
4. **Elastic IP 할당 (고정 IP)**

---
작성일: 2025년 8월