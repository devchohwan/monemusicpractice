# Puma 프로덕션 설정
# config/puma_production.rb

# 워커 프로세스 수
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# 스레드 수
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# 소켓 경로
bind "unix:///var/www/monemusicpractice/shared/tmp/sockets/puma.sock"

# 환경
environment ENV.fetch("RAILS_ENV") { "production" }

# PID 파일
pidfile "/var/www/monemusicpractice/shared/tmp/pids/puma.pid"

# 로그 파일
stdout_redirect '/var/www/monemusicpractice/log/puma.stdout.log',
                '/var/www/monemusicpractice/log/puma.stderr.log', true

# Preload
preload_app!

# 데몬으로 실행
daemonize true