class SaveDataService
  attr_reader :data, :contact, :hot_deal

  def initialize(data, hot_deal)
    @data = data
    @contact = data[:agent]
    @hot_deal = hot_deal
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
      home_type: data[:home_type],
      home_status: data[:home_status],
      bedroom: data[:bedroom],
      bathroom: data[:bathroom],
      dom_cdom: data[:dom_cdom],
      remark: data[:remark],
      agent_id: agent.id,
      hot_deal: hot_deal,
      comp: data[:comp]
    )
    deal.save
  end

  def save_agent
    agent = Agent.find_or_initialize_by(
      full_name: contact[:full_name],
      first_name: contact[:first_name],
      last_name: contact[:last_name]
    )
    agent.phone = contact[:phone]
    agent.email = contact[:email]
    agent.office_name = contact[:office_name]
    agent.save and agent
  end
end
