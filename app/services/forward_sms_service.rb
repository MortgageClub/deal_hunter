require 'plivo'

class ForwardSmsService
  include Plivo

  AUTH_ID = ENV["PLIVO_AUTH_ID"]
  AUTH_TOKEN = ENV["PLIVO_AUTH_TOKEN"]
  PLIVO_SENDER = ENV["PLIVO_SENDER"]
  BILLY_PHONE_NUMBER = "16507877799"

  attr_reader :agent, :message

  def initialize(agent, message)
    @agent = agent
    @message = message
  end

  def call
    content = "#{message.content} - #{agent.to_s}: #{message.phone_number}. address: #{deal_address}"
    forward(content)
  end

  private

  def deal_address
    deals = Deal.where(agent_id: agent.id)
    deals.inject('') { |address, deal| address + "#{deal.address}, #{deal.city}. " }
  end

  def forward(content)
    plivo = RestAPI.new(AUTH_ID, AUTH_TOKEN)
    params = {
      'src' => PLIVO_SENDER,
      'dst' => BILLY_PHONE_NUMBER,
      'text' => content
    }
    plivo.send_message(params)
  end
end