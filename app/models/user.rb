class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, authentication_keys: [:username]
         
  TEACHERS = ['무성', '성균', '노네임', '로한', '범석', '두박', '오또', '지명', '도현'].freeze
  
  has_many :reservations, dependent: :destroy
  has_many :penalties, dependent: :destroy
  
  validates :username, presence: true, uniqueness: true
  validates :name, presence: true
  validates :teacher, presence: true, inclusion: { in: TEACHERS }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }
  
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
end
