class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: [:show, :cancel, :destroy]
  
  def index
    @reservations = current_user.reservations.includes(:room)
    
    # 상태 필터링
    if params[:status].present?
      case params[:status]
      when 'active'
        @reservations = @reservations.where(status: 'active').where('end_time > ?', Time.current)
      when 'completed'
        @reservations = @reservations.where('(status = ? OR (status = ? AND end_time <= ?))', 'completed', 'active', Time.current)
      when 'cancelled'
        @reservations = @reservations.where(status: 'cancelled')
      when 'no_show'
        @reservations = @reservations.where(status: 'no_show')
      end
    end
    
    # 날짜 필터링
    if params[:date].present?
      date = Date.parse(params[:date])
      start_of_day = date.beginning_of_day
      end_of_day = date.end_of_day
      @reservations = @reservations.where(start_time: start_of_day..end_of_day)
    end
    
    @reservations = @reservations.order(start_time: :desc)
  end
  
  def new
    if current_user.blocked?
      flash[:alert] = '월 2회 이상 노쇼/취소하여 이용이 제한되었습니다'
      redirect_to root_path
      return
    end
    
    @reservation = Reservation.new
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
  end
  
  def create
    @reservation = current_user.reservations.build(reservation_params)
    
    if @reservation.save
      redirect_to reservations_path, notice: '예약이 완료되었습니다.'
    else
      flash[:alert] = '이미 예약하셨습니다. 예약한 시간을 먼저 사용해주세요'
      redirect_to new_reservation_path
    end
  end
  
  def show
  end
  
  def cancel
    if @reservation.cancellable?
      @reservation.update(status: 'cancelled')
      redirect_to reservations_path, notice: '예약이 취소되었습니다.'
    else
      redirect_to reservations_path, alert: '예약 시작 30분 전까지만 취소 가능합니다.'
    end
  end
  
  def destroy
    @reservation.destroy if current_user.is_admin?
    redirect_to reservations_path
  end
  
  def calendar
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @selected_date = params[:selected_date] ? Date.parse(params[:selected_date]) : nil
    
    render partial: 'calendar', locals: { date: @date, selected_date: @selected_date }
  end
  
  def time_slots
    @date = Date.parse(params[:date])
    @time_slots = generate_time_slots(@date)
    
    render partial: 'time_slots', locals: { time_slots: @time_slots, date: @date }
  end
  
  def available_rooms
    start_time = Time.parse(params[:start_time])
    end_time = Time.parse(params[:end_time])
    
    @all_rooms = Room.order(:number).map do |room|
      {
        room: room,
        available: room.available_at?(start_time, end_time)
      }
    end
    
    render partial: 'available_rooms', locals: { rooms_data: @all_rooms }
  end
  
  private
  
  def set_reservation
    @reservation = current_user.reservations.find(params[:id])
  end
  
  def reservation_params
    params.require(:reservation).permit(:room_id, :start_time, :end_time)
  end
  
  def generate_time_slots(date)
    slots = []
    current_time = Time.current
    
    # 13:00부터 21:30까지 30분 단위 (브레이크타임 제외)
    (13..21).each do |hour|
      [0, 30].each do |minute|
        time = date.to_time.in_time_zone('Seoul') + hour.hours + minute.minutes
        
        # 현재 시간보다 과거면 스킵 (30분 여유 시간 추가)
        next if time <= current_time + 30.minutes
        
        # 브레이크타임 (17:30, 18:00, 18:30) 제외
        hour_minute = hour * 100 + minute
        next if hour_minute == 1730 || hour_minute == 1800 || hour_minute == 1830
        
        slots << {
          time: time,
          display: time.strftime('%H:%M'),
          period: case hour
                  when 13..17 then '오후'
                  else '저녁'
                  end
        }
      end
    end
    
    slots
  end
end