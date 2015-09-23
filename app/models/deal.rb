class Deal < ActiveRecord::Base
  belongs_to :agent

  validates :price, :zestimate, :address, :city, :zipcode, :agent_id, presence: true
end
