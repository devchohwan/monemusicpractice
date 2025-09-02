class Admin::ReservationsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_reservation, only: [:destroy, :update_status]
  
  def index
    @reservations = Reservation.includes(:user, :room)
                               .order(start_time: :desc)
    
    # 검색 기능 (이름/아이디)
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @reservations = @reservations.joins(:user)
                                  .where("users.name LIKE ? OR users.username LIKE ?", search_term, search_term)
    end
    
    # 필터링 옵션
    if params[:status].present?
      @reservations = @reservations.where(status: params[:status])
    end
    
    if params[:date].present?
      date = Date.parse(params[:date])
      @reservations = @reservations.where(start_time: date.beginning_of_day..date.end_of_day)
    end
    
    @users = User.all
  end
  
  def destroy
    @reservation.destroy
    redirect_params = {}
    redirect_params[:search] = params[:search] if params[:search].present?
    redirect_params[:status] = params[:status] if params[:status].present?
    redirect_params[:date] = params[:date] if params[:date].present?
    redirect_to admin_reservations_path(redirect_params), notice: '예약이 삭제되었습니다.'
  end
  
  def update_status
    redirect_params = {}
    redirect_params[:search] = params[:search] if params[:search].present?
    redirect_params[:status] = params[:filter_status] if params[:filter_status].present?
    redirect_params[:date] = params[:date] if params[:date].present?
    
    if @reservation.update(status: params[:status])
      redirect_to admin_reservations_path(redirect_params), notice: '예약 상태가 변경되었습니다.'
    else
      redirect_to admin_reservations_path(redirect_params), alert: '상태 변경에 실패했습니다.'
    end
  end
  
  private
  
  def set_reservation
    @reservation = Reservation.find(params[:id])
  end
end