class User < ActiveRecord::Base

	enum role: [:user, :admin]
  after_initialize :set_default_role
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :messages, as: :messageable, dependent: :destroy

  validates :email, presence: true

  def to_s
    name
  end

  private

  def set_default_role
    self.role ||= :user
  end
end
