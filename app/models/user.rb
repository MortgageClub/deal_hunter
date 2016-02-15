class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  enum role: [:user, :admin]
  after_initialize :set_default_role, if: :new_record?
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :messages, as: :messageable, dependent: :destroy

  validates :email, :name, presence: true

  def to_s
    name
  end

  def set_default_role
    self.role ||= :user
  end
end
