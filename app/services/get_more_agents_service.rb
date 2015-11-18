require 'capybara'
require 'capybara/poltergeist'

class GetMoreAgentsService
  include Capybara::DSL
  TD_COLUMN    = "td".freeze
  BLANK_SPACE  = "".freeze
  WHITE_SPACE  = " ".freeze

  def self.call
    set_up_crawler
    login
    go_to_sfar_mls
    # crawl_data
  end

  private

  def self.login
    @session.visit("http://www.reil.com/")
    @session.click_link("TopNavigation1_rpNavTop_SignIn_4")
    sleep(5)
    fill_login_form
    sleep(5)
    @session.visit("https://connect.mlslistings.com/SAML/CSAuthnRequestIssuer.ashx?RelayUrl=http://pro.mlslistings.com/")
    sleep(5)
    fill_login_form
    sleep(5)
  end

  def self.fill_login_form
    # @session.execute_script("$('#MainContent_UCLogin_ibtnSignIn').trigger('click')")
    # sleep(5)
    @session.execute_script("$('#j_username').val('01972404')")
    @session.execute_script("$('#password').val('Blackdawn1')")
    @session.execute_script("$('#j_password').val('Blackdawn1')")
    @session.execute_script("$('#login').trigger('click')")
  end

  def self.go_to_sfar_mls
    @session.click_link("MainContent_OtherMLS1_rpOtherApplications_SFO_5")
    @session.visit("http://qtrosso.rapmls.com/sp/startSSO.ping?PartnerIdpId=MLSListingsIdentityProvider&TargetResource=http%3a%2f%2fportal.rapmls.com%2fSFAR%2fSpSSOHandler.aspx%3furl%3dhttp%3a%2f%2flogin.rapmls.com%2fSFAR%2fhomepage.aspx")
    @session.execute_script("$('#MainContent_btnContinue').trigger('click')")
    sleep(10)
    @session.execute_script("$('#btnContinue').trigger('click')")
    byebug
  end

  def self.set_up_crawler
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {js_errors: false, timeout: 60})
    end
    @session = Capybara::Session.new(:poltergeist)
    # @session.driver.headers = { "User-Agent" => "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36" }
    # @session = Capybara::Session.new(:selenium)
  end
end
