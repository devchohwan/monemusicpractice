class Room < ApplicationRecord
  has_many :reservations, dependent: :destroy
  
  validates :number, presence: true, uniqueness: true, inclusion: { in: 1..8 }
  
  scope :with_outlet, -> { where(has_outlet: true) }
  scope :without_outlet, -> { where(has_outlet: false) }
  
  def available_at?(start_time, end_time, exclude_reservation_id = nil)
    query = reservations.where(status: 'active')
                       .where('start_time < ? AND end_time > ?', end_time, start_time)
    query = query.where.not(id: exclude_reservation_id) if exclude_reservation_id
    query.none?
  end
end
