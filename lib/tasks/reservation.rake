namespace :reservation do
  desc "시간이 지난 활성 예약을 완료 상태로 변경"
  task update_completed: :environment do
    completed_count = 0
    
    # 종료 시간이 지난 활성 예약들을 찾아서 완료로 변경
    Reservation.where(status: 'active')
               .where('end_time < ?', Time.current)
               .find_each do |reservation|
      reservation.update(status: 'completed')
      completed_count += 1
    end
    
    puts "#{completed_count}개의 예약이 완료 상태로 변경되었습니다."
  end
end