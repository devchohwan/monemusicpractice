class Penalty < ApplicationRecord
  belongs_to :user
  
  validates :month, presence: true, inclusion: { in: 1..12 }
  validates :year, presence: true
  validates :user_id, uniqueness: { scope: [:month, :year] }
  
  scope :current_month, -> { where(month: Date.current.month, year: Date.current.year) }
  scope :blocked, -> { where(is_blocked: true) }
  
  def total_violations
    no_show_count + cancel_count
  end
end
