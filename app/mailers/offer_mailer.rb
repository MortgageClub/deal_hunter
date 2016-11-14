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

  def notify_customer(listing)
    @listing = listing

    mail(
      from: "Billy Tran <#{listing.market.from_email}>",
      to: listing.market.to_email,
      subject: "Make an offer for #{listing.address.to_s.titleize}, #{listing.city.to_s.titleize}"
    )
  end
end
