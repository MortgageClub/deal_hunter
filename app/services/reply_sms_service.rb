require 'plivo'

class ReplySmsService
  include Plivo

  AUTH_ID = ENV["PLIVO_AUTH_ID"]
  AUTH_TOKEN = ENV["PLIVO_AUTH_TOKEN"]
  PLIVO_SENDER = ENV["PLIVO_SENDER"]

  def self.call(message)
    plivo = RestAPI.new(AUTH_ID, AUTH_TOKEN)
    params = {
      'src' => PLIVO_SENDER,
      'dst' => message.phone_number,
      'text' => message.reply
    }
    plivo.send_message(params)
  end
end