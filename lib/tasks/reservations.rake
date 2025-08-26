namespace :reservations do
  desc "지난 활성 예약을 노쇼로 처리"
  task update_past_reservations: :environment do
    # 종료 시간이 지났지만 여전히 active 상태인 예약들을 찾아서 처리
    past_active_reservations = Reservation.active.where('end_time < ?', Time.current)
    
    past_active_reservations.each do |reservation|
      reservation.mark_as_no_show!
      puts "예약 ##{reservation.id} (#{reservation.user.name}) - 노쇼 처리됨"
    end
    
    puts "#{past_active_reservations.count}개의 예약이 노쇼로 처리되었습니다."
  end
  
  desc "테스트용: 모든 지난 예약을 completed로 처리 (패널티 없음)"
  task complete_past_reservations: :environment do
    past_active_reservations = Reservation.active.where('end_time < ?', Time.current)
    
    past_active_reservations.each do |reservation|
      reservation.update_columns(status: 'completed', updated_at: Time.current)
      puts "예약 ##{reservation.id} (#{reservation.user.name}) - 완료 처리됨"
    end
    
    puts "#{past_active_reservations.count}개의 예약이 완료로 처리되었습니다."
  end
end