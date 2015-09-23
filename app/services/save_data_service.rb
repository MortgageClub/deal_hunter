class SaveDataService
  attr_reader :data, :contact

  def initialize(data)
    @data = data
    @contact = data[:agent]
  end

  def call
    agent = save_agent
    save_deal(agent) if agent.persisted?
  end

  private

  def save_deal(agent)
    deal = Deal.new(
      listing_id: data[:listing_id],
      price: data[:price],
      zestimate: data[:zestimate],
      address: data[:address],
      city: data[:city],
      zipcode: data[:zipcode],
      agent_id: agent.id
    )
    deal.save
  end

  def save_agent
    agent = Agent.new(
      full_name: contact[:full_name],
      first_name: contact[:first_name],
      last_name: contact[:last_name],
      phone: contact[:phone],
      email: contact[:email],
      office_name: contact[:office_name]
    )
    agent.save and agent
  end
end
