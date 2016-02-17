require 'rubygems'
require 'plivo'

class SendSmsToAgentService
  include Plivo

  AUTH_ID = ENV["PLIVO_AUTH_ID"]
  AUTH_TOKEN = ENV["PLIVO_AUTH_TOKEN"]
  PLIVO_SENDER = ENV["PLIVO_SENDER"]
  BILLY_PHONE_NUMBER = "16507877799"

  def self.call(phone_number, agent_name, property_address)
    plivo = RestAPI.new(AUTH_ID, AUTH_TOKEN)

    # Send SMS
    params = {
      'src' => PLIVO_SENDER, # Sender's phone number with country code
      'dst' => phone_number, # Receiver's phone Number with country code
      'text' => "Hello #{agent_name}, my name is Billy and I'm a buyer interested in #{property_address}. Can you show me the house and help me make a cash offer? Thanks."
    }
    plivo.send_message(params)
  end
end
