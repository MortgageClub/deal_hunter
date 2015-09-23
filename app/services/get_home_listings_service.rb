require 'capybara'
require 'capybara/poltergeist'

class GetHomeListingsService
  include Capybara::DSL

  def self.call
    set_up_crawler
    login
    go_to_metro_list
    crawl_data
  end

  private

  def self.login
    @session.visit("https://connect.mlslistings.com/SAML/CSAuthnRequestIssuer.ashx?RelayUrl=http://pro.mlslistings.com/")
    @session.execute_script("$('#j_username').val('01972404')")
    @session.execute_script("$('#password').val('Blackdawn1')")
    @session.execute_script("$('#j_password').val('Blackdawn1')")
    @session.click_on("SIGN IN")
    sleep(10)
  end

  def self.go_to_metro_list
    @session.click_link("MainContent_OtherMLS1_rpOtherApplications_SACM_3")
    @session.visit("http://qtrosso.rapmls.com/sp/startSSO.ping?PartnerIdpId=MLSListingsIdentityProvider&TargetResource=http://login.rapmls.com/SACM/','SACM'")
    @session.execute_script("$('#btnContinue').trigger('click')")
    sleep(5)
  end

  def self.crawl_data
    session_id = @session.current_url.split("&SID=").last
    count = 0
    data = Nokogiri::HTML.parse(@session.html)
    while data.css(".subject-list-grid").empty? && count < 5
      @session.visit("http://search.metrolist.net/ListingGridDisplay.aspx?hidMLS=SACM&GRID=137130&PTYPE=RESI&SRC=HS&SRID=211618742&PRINT=0&SAS=0&ARCH=0&HIDD=0&REMO=0&SNAME=Sacramento+Hotsheet&CARTID=&SPLISTINGRID=0&STYPE=HS&SID=#{session_id}")
      data = Nokogiri::HTML.parse(@session.html)
      count += 1
      sleep(5)
    end

    return if data.css(".subject-list-grid").empty?

    data = Nokogiri::HTML.parse(@session.html)
    result = []
    table = data.css(".subject-list-grid")
    table.css("tr").each do |tr|
      next if tr.css("td").size < 2

      listing_id = tr.css("td")[1].text
      address = tr.css("td")[4].text
      city = tr.css("td")[5].text
      zipcode = tr.css("td")[6].text
      price = tr.css("td")[7].text.gsub(/[^0-9\.]/,'')
      full_name = tr.css("td")[12].text.strip
      first_name = full_name.split(" ").first
      last_name = full_name.split(" ").last
      agent_email = tr.css("td")[13].text
      agent_phone = tr.css("td")[14].text
      office_name = tr.css("td")[15].text

      result << {
        listing_id: listing_id, price: price, address: address,
        city: city, zipcode: zipcode,
        agent: {
          full_name: full_name,
          first_name: first_name,
          last_name: last_name,
          phone: agent_phone,
          email: agent_email,
          office_name: office_name
        }
      }
    end
    result
  end

  def self.set_up_crawler
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {js_errors: false, timeout: 60})
    end
    @session = Capybara::Session.new(:poltergeist)
    @session.driver.headers = { "User-Agent" => "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36" }
    # @session = Capybara::Session.new(:selenium)
  end
end

# [
  # [19] {
  #     :listing_id => "15049016",
  #          :price => "160000",
  #        :address => "1525 Katharine Ave",
  #           :city => "Sacramento",
  #        :zipcode => "95838",
  #          :agent => {
  #           :full_name => "Ron D Allen",
  #          :first_name => "Ron",
  #           :last_name => "Allen",
  #               :phone => "916-807-1210",
  #               :email => "drallenifbc@yahoo.com",
  #         :office_name => "Ron Allen & Associates Real Estate"
  #     }
  # },
  # [20] {
  #     :listing_id => "15054201",
  #          :price => "151900",
  #        :address => "5626 Revelstok Dr",
  #           :city => "Sacramento",
  #        :zipcode => "95842",
  #          :agent => {
  #           :full_name => "Michael J Taylor",
  #          :first_name => "Michael",
  #           :last_name => "Taylor",
  #               :phone => "916-878-1754",
  #               :email => "mike@intrustrg.com",
  #         :office_name => "HomeSmart Intrust Realty Group"
  #     }
  # }
# ]