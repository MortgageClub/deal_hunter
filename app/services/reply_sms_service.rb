require 'plivo'

class ReplySmsService
  include Plivo

  def self.call(message)
    plivo = RestAPI.new(ENV["PLIVO_AUTH_ID"], ENV["PLIVO_AUTH_TOKEN"])
    params = {
      'src' => ENV["PLIVO_SENDER"],
      'dst' => message.phone_number,
      'text' => message.reply
    }
    plivo.send_message(params)
  end
end