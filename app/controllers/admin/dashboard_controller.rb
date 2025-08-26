class Admin::DashboardController < ApplicationController
  before_action :authenticate_admin!
  
  def index
    @pending_users = User.pending.count
    @total_users = User.count
    @todays_reservations = Reservation.today.count
    # 이용 전 예약: active 상태이면서 현재 시간 이후에 끝나는 예약
    @active_reservations = Reservation.where(status: 'active')
                                      .where('end_time > ?', Time.current)
                                      .count
  end
end