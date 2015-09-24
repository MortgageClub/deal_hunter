class Agent < ActiveRecord::Base
  has_many :deals
  has_many :messages, as: :messageable

  validates :full_name, :first_name, :phone, :email, presence: true
end
