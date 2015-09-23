class Agent < ActiveRecord::Base
  has_many :deals

  validates :full_name, :first_name, :phone, :email, presence: true
end
