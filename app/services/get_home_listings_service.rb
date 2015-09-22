require 'capybara'
require 'capybara/poltergeist'

class GetHomeListingsService
  include Capybara::DSL

  def self.call
    set_up_crawler
    login
    go_to_metro_list
  end

  private

  def self.login
    @session.visit("https://connect.mlslistings.com/SAML/CSAuthnRequestIssuer.ashx?RelayUrl=http://pro.mlslistings.com/")
    @session.execute_script("$('#j_username').val('01972404')")
    @session.execute_script("$('#password').val('Blackdawn1')")
    @session.execute_script("$('#j_password').val('Blackdawn1')")
    # @session.execute_script("$('form#loginform').submit()")
    @session.click_on("SIGN IN")
    sleep(8)
    # @session.execute_script("$('#password').val(Blackdawn1)")
    #
    # sleep(10)
    # @session.find('#login').native.send_keys(:return)

    # fill in form
  end

  def self.go_to_metro_list
    @session.click_link("MainContent_OtherMLS1_rpOtherApplications_SACM_3")
    @session.visit("http://qtrosso.rapmls.com/sp/startSSO.ping?PartnerIdpId=MLSListingsIdentityProvider&TargetResource=http://login.rapmls.com/SACM/','SACM'")
    @session.execute_script("$('#btnContinue').trigger('click')")
    byebug
    session_id = @session.current_url.split("&SID=").last
    byebug
    # @session.visit("http://search.metrolist.net/PropertyTypeTab.aspx?hidMLS=SACM&DTYPE=HS&SRID=211378545&STYPE=HS&DCODE=&SNAME=Sac+under+160k&SID=#{session_id}")
    # @session.visit("http://search.metrolist.net/Search.aspx?hidMLS=SACM&Action=7&SearchRID=211378545&SessionNumber=182966228&ProspectName=&PropspectRID=&SearchName=Sac+under+160k&SearchType=HS&SID=#{session_id}")
    @session.visit("http://search.metrolist.net/ListingGridDisplay.aspx?hidMLS=SACM&GRID=137130&PTYPE=RESI&SRC=HS&SRID=211378545&PRINT=0&SAS=0&ARCH=0&HIDD=0&REMO=0&SNAME=Sac+under+160k&CARTID=&SPLISTINGRID=0&STYPE=HS&SID=#{session_id}")
    sleep(10)
    byebug
    @session.execute_script("SetListings()");
    byebug
    data = Nokogiri::HTML.parse(@session.html)
    byebug
  end

  def self.set_up_crawler
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {js_errors: false})
    end
    @session = Capybara::Session.new(:poltergeist)
    # @session = Capybara::Session.new(:selenium)
  end
end