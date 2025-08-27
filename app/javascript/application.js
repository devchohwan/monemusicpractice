// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { Turbo } from "@hotwired/turbo-rails"

// Turbo 캐시 비활성화
Turbo.session.drive = false

// CSRF 토큰 자동 포함 설정
document.addEventListener("turbo:before-fetch-request", (event) => {
  const token = document.querySelector('meta[name="csrf-token"]').content
  event.detail.fetchOptions.headers["X-CSRF-Token"] = token
})
