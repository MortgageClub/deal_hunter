class OfferMailer < ActionMailer::Base
  default :from => ENV['EMAIL_SENDER']

  def notify_agent(name, email, address, city)
    @agent_email = email
    @agent_name = name
    @property_address = address + ', ' + city
    mail(
      to: email,
      subject: "Offer for #{@property_address}"
    )
  end
end
