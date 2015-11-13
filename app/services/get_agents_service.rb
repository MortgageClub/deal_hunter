require 'capybara'
require 'capybara/poltergeist'

class GetAgentsService
  include Capybara::DSL
  TD_COLUMN    = "td".freeze
  BLANK_SPACE  = "".freeze
  WHITE_SPACE  = " ".freeze

  def self.call
    @start_time = Time.now
    p @start_time
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
    @session.execute_script("$('#login').trigger('click')")
    sleep(20)
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
    key = data.search('a[key="V"]')[0].attr('url').split('-')[1].delete(',')

    user_id = Setting.i(:crawler_last_agent_id) + 1
    puts "last id: #{user_id}"

    (user_id..Setting.i(:crawler_max_agent_id)).each do |id|
      break if Time.now > (@start_time + 4.minutes) # break after 4 minutes
      Setting[:crawler_last_agent_id] = id
      puts "--- #{id} ---"

      agent_info_url = "http://prospector.metrolist.net/scripts/mgrqispi.dll?APPNAME=Metrolist&PRGNAME=MLSListingAgentDetail&ARGUMENTS=-N#{id},-#{key}"
      @session.visit(agent_info_url)
      agent_data = Nokogiri::HTML.parse(@session.html).at_css('#Workspace')
      next if agent_data.blank?

      full_name = agent_data.at_css('.bBlackTextB').children.first.to_s.strip
      next if full_name.blank?
      first_name = full_name.split(WHITE_SPACE).first
      last_name = full_name.split(WHITE_SPACE).last

      office_name = agent_data.at_css('#aOfficeInfo').text.strip

      email_data = agent_data.search("[text()*='E-mail']").first.parent.parent.css('a').last
      email = email_data.text if email_data.present?
      next if email.blank?

      phone_data = agent_data.search("[text()*='Office']").first.parent.parent.css('.mBlackText').last
      phone =  "1".freeze + phone_data.text.gsub("-".freeze, BLANK_SPACE) if phone_data.present?

      contact_data = agent_data.search("[text()*='Contact']")
      contact = contact_data.first.parent.parent.css('.mBlackText').last.text if contact_data.present?

      fax_data = agent_data.search("[text()*='Fax']")
      fax = fax_data.first.parent.parent.css('.mBlackText').last.text if fax_data.present?

      lic_data = agent_data.search("[text()*='Lic:']")
      lic = lic_data.first.parent.parent.css('.mBlackText').last.text if lic_data.present?

      web_page_data = agent_data.search("[text()*='Web Page']")
      web_page = web_page_data.first.parent.parent.css('a').last.text if web_page_data.present?

      # Save agent
      puts "#{full_name}, #{phone}, #{email}, #{office_name}, #{contact}, #{fax}, #{lic}, #{web_page}"
      agent = Agent.find_or_initialize_by(
        full_name: full_name,
        first_name: first_name,
        last_name: last_name
      )
      agent.phone = phone
      agent.email = email
      agent.office_name = office_name
      agent.contact = contact
      agent.fax = fax
      agent.lic = lic
      agent.web_page = web_page
      agent.save
    end
  end

  def self.set_up_crawler
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {js_errors: false, timeout: 60})
    end
    @session = Capybara::Session.new(:poltergeist)
  end
end