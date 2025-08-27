class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :room
  
  STATUSES = %w[active completed cancelled no_show].freeze
  
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :validate_time_range
  validate :validate_no_overlap
  validate :validate_cancellation_time
  
  scope :active, -> { where(status: 'active') }
  scope :future, -> { where('start_time > ?', Time.current) }
  scope :past, -> { where('end_time < ?', Time.current) }
  scope :ongoing_or_future, -> { where('end_time >= ?', Time.current) }
  scope :today, -> { where(start_time: Date.current.beginning_of_day..Date.current.end_of_day) }
  
  before_create :check_user_eligibility
  after_update :handle_status_change
  
  def cancellable?
    status == 'active' && start_time > 30.minutes.from_now
  end
  
  def mark_as_completed!
    update!(status: 'completed') if status == 'active' && end_time < Time.current
  end
  
  def mark_as_no_show!
    update!(status: 'no_show') if status == 'active' && end_time < Time.current
  end
  
  def status_display
    return status unless status == 'active'
    
    current_time = Time.current
    
    if current_time < start_time
      '이용 전'
    elsif current_time >= start_time && current_time < end_time
      '이용 중'
    elsif current_time >= end_time
      '완료'
    else
      status
    end
  end
  
  private
  
  def validate_time_range
    return unless start_time && end_time
    
    errors.add(:end_time, '종료 시간은 시작 시간 이후여야 합니다') if end_time <= start_time
    errors.add(:start_time, '과거 시간은 예약할 수 없습니다') if start_time < Time.current && new_record?
  end
  
  def validate_no_overlap
    return unless room && start_time && end_time
    
    overlapping = room.reservations
                     .where(status: 'active')
                     .where('start_time < ? AND end_time > ?', end_time, start_time)
    overlapping = overlapping.where.not(id: id) unless new_record?
    
    errors.add(:base, '해당 시간에 이미 예약이 있습니다') if overlapping.exists?
  end
  
  def validate_cancellation_time
    if status_changed? && status_was == 'active' && status == 'cancelled'
      if start_time <= 30.minutes.from_now
        errors.add(:base, '예약 시작 30분 전까지만 취소 가능합니다')
      end
    end
  end
  
  def check_user_eligibility
    if user.blocked?
      errors.add(:base, '이번 달은 패널티로 인해 예약이 불가능합니다')
      throw(:abort)
    end
    
    # 시작했지만 아직 끝나지 않은 활성 예약이 있는지 확인 (노쇼 체크용)
    if user.reservations.active.where('start_time < ? AND end_time > ?', Time.current, Time.current).exists?
      errors.add(:base, '현재 진행 중인 예약을 사용하지 않아 새로운 예약이 불가능합니다')
      throw(:abort)
    end
    
    # 아직 끝나지 않은 활성 예약이 있는지 확인 (현재 진행중 + 미래 예약 모두 포함)
    if user.reservations.active.where('end_time > ?', Time.current).exists?
      errors.add(:base, '이미 예약이 있습니다. 예약 시간이 끝난 후에 새로운 예약이 가능합니다')
      throw(:abort)
    end
  end
  
  def handle_status_change
    return unless saved_change_to_status?
    
    penalty = user.current_month_penalty
    
    case status
    when 'cancelled'
      penalty.increment!(:cancel_count)
    when 'no_show'
      penalty.increment!(:no_show_count)
    end
    
    if penalty.cancel_count + penalty.no_show_count >= 2
      penalty.update!(is_blocked: true)
    end
  end
end