class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, authentication_keys: [:username]
         
  TEACHERS = ['무성', '성균', '노네임', '로한', '범석', '두박', '오또', '지명', '도현'].freeze
  STATUSES = ['pending', 'approved', 'on_hold'].freeze
  
  has_many :reservations, dependent: :destroy
  has_many :penalties, dependent: :destroy
  
  validates :username, presence: true, uniqueness: true
  validates :name, presence: true
  validates :teacher, presence: true, inclusion: { in: TEACHERS }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :status, presence: true, inclusion: { in: STATUSES }
  
  before_validation :set_admin_status
  before_save :protect_admin_status
  
  scope :approved, -> { where(status: 'approved') }
  scope :pending, -> { where(status: 'pending') }
  scope :on_hold, -> { where(status: 'on_hold') }
  
  def approved?
    status == 'approved'
  end
  
  def pending?
    status == 'pending'
  end
  
  def on_hold?
    status == 'on_hold'
  end
  
  def active_for_authentication?
    super && approved?
  end
  
  def inactive_message
    approved? ? super : :not_approved
  end
  
  def current_month_penalty
    penalties.find_or_create_by(month: Date.current.month, year: Date.current.year)
  end
  
  def blocked?
    current_month_penalty.is_blocked?
  end
  
  private
  
  def set_admin_status
    if is_admin? && status != 'approved'
      self.status = 'approved'
    end
  end
  
  def protect_admin_status
    if is_admin? && status != 'approved'
      self.status = 'approved'
    end
  end
end
