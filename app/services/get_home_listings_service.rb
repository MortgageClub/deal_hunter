require 'capybara'
require 'capybara/poltergeist'

class GetHomeListingsService
  include Capybara::DSL

  def self.call
    set_up_crawler
    login
    # go_to_metro_list
  end

  private

  def self.login
    @session.visit "https://connect.mlslistings.com/SAML/CSAuthnRequestIssuer.ashx?RelayUrl=http://pro.mlslistings.com/"
    sleep(5)
    @session.fill_in("j_username", with: "01972404")
    @session.fill_in("password", with: "Blackdawn1")
    @session.execute_script("$('form#loginform').submit()")
    byebug

    # @session.find('#login').native.send_keys(:return)
    # @session.click_button("login")
    # fill in form
  end

  def self.go_to_metro_list
    @session.visit "http://search.metrolist.net/PropertyTypeTab.aspx?hidMLS=SACM&DTYPE=HS&SRID=211378545&STYPE=HS&DCODE=&SNAME=Sac+under+160k&SID=c0f5210c-c614-448c-b4a8-64e88d75a609"
  end

  def self.set_up_crawler
    # Capybara.register_driver :poltergeist do |app|
    #   Capybara::Poltergeist::Driver.new(app, {js_errors: false})
    # end
    # @session = Capybara::Session.new(:poltergeist)
    # @session.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
    @session = Capybara::Session.new(:selenium)
  end
end