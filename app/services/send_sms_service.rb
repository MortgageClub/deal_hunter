require 'rubygems'
require 'plivo'

class SendSmsService
  include Plivo

  AUTH_ID = ENV["PLIVO_AUTH_ID"]
  AUTH_TOKEN = ENV["PLIVO_AUTH_TOKEN"]

  def self.call(phone_number, agent_name, property_address)
    plivo = RestAPI.new(AUTH_ID, AUTH_TOKEN)

    # Send SMS
    params = {
      'src' => ENV["PLIVO_SENDER"], # Sender's phone number with country code
      'dst' => phone_number,        # Receiver's phone Number with country code
      'text' => "Hello #{agent_name}, \n My name is Billy and I'm a buyer interested in #{property_address}. Is it still available? Can you show me the house and help me make an offer? I'm going to send u an email as well. Thank you."
    }
    response = plivo.send_message(params)
    # uuid = response[1]['message_uuid'][0]

    # params1 = {
    #     'record_id' => uuid
    # }
    # response = plivo.get_message(params1)
    p response
  end

end