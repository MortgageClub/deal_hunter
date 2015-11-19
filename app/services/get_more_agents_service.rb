require 'capybara'
require 'capybara/poltergeist'

class GetMoreAgentsService
  include Capybara::DSL

  COUNTRIES = ["San Francisco", "San Mateo", "Alameda", "Contra Costa", "Los Angeles",
      "Santa Clara", "Santa Cruz", "Solano", "Sonoma", "Alpine", "Amador", "Bear Lake",
      "Butte", "Calaveras", "Colusa", "Del Norte", "El Dorado", "Fresno", "Glenn", "Humboldt",
      "Imperial", "Inyo", "Kern", "Kings", "Lake", "Lassen", "Madera", "Maricopa", "Marin",
      "Mariposa", "Mendocino", "Merced", "Modoc", "Mono", "Monterey", "Napa", "Nevada", "Orange",
      "Placer", "Plumas", "Pocono", "Riverside", "Sacramento", "San Benito", "San Bernardino",
      "San Diego", "San Joaquin", "San Luis Obispo", "San Miguel", "Santa Barbara", "Shasta",
      "Sierra", "Siskiyou", "Stanislaus", "Sutter", "Tehama", "Trinity", "Tulare", "Tuolumne",
      "Ventura", "Yakima", "Yolo", "Yuba"]

  def self.call
    set_up_crawler
    # login
    # go_to_sfar_mls

    COUNTRIES.each do |country|
      ("A".."Z").each do |keyword|
        puts "--- country: #{country}, key: #{keyword} ---"
        fill_search_form(keyword, country)
      end
    end
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
  end

  def self.fill_login_form
    @session.execute_script("$('#j_username').val('01972404')")
    @session.execute_script("$('#password').val('Blackdawn1')")
    @session.execute_script("$('#j_password').val('Blackdawn1')")
    @session.execute_script("$('#login').trigger('click')")
  end

  def self.go_to_sfar_mls
    sleep(20)
    @session.click_link("MainContent_OtherMLS1_rpOtherApplications_SFO_5")
    @session.visit("http://qtrosso.rapmls.com/sp/startSSO.ping?PartnerIdpId=MLSListingsIdentityProvider&TargetResource=http%3a%2f%2fportal.rapmls.com%2fSFAR%2fSpSSOHandler.aspx%3furl%3dhttp%3a%2f%2flogin.rapmls.com%2fSFAR%2fhomepage.aspx")
    @session.execute_script("$('#MainContent_btnContinue').trigger('click')")
    sleep(10)
    @session.execute_script("$('#btnContinue').trigger('click')")
    sleep(7)
  end

  def self.agent_office_link
    data = Nokogiri::HTML.parse(@session.html, nil, 'utf-8')
    link = ''
    data.css('a').each do |a|
      if a.attr('key') == "G"
        link = a.attr('url')
        break
      end
    end
    link
  end

  def self.fill_search_form (last_name, country)
    # ---
    @session.visit("http://sfarmls.rapmls.com/scripts/mgrqispi.dll?APPNAME=Sanfrancisco&PRGNAME=MLSAgentsandOffices&ARGUMENTS=-N167345231&SID=6177e444-6ef4-4db3-9d3e-5b9497e12622")
    # -----
    # @session.visit(agent_office_link)
    # p agent_office_link

    @session.execute_script("$('#Agent_Lastname').val('#{last_name}')")
    @session.execute_script("$('#County_Fill_In').val('#{country}')")
    @session.execute_script("$('form.PageForm').submit()")
    sleep(5)

    data = Nokogiri::HTML.parse(@session.html, nil, 'utf-8')
    even_data = data.css(".bgLightBlueBarsBlackText")
    odd_data = data.css(".bgWhiteBarsBlackText")

    even_data.each {|d| save_agent(d, country)}
    odd_data.each {|d| save_agent(d, country)}
  end

  def self.save_agent(data, country)
    begin
      full_name = data.css('td')[3].text
      return if full_name.blank?
      first_name = full_name.split(',').first.strip
      last_name = full_name.split(',').last.strip
      office_name = data.css('td')[4].text
      address = data.css('td')[5].text
      phone = '1' + data.css('td')[6].text.gsub('-', '').gsub("\u00a0", '') if data.css('td')[6].text.present?

      agent_id = data.css('td')[3].at_css('.mBlueLink').attr('href').gsub('javascript:ViewAgent(', '').gsub(')', '')

      @session.visit("http://sfarmls.rapmls.com/scripts/mgrqispi.dll?APPNAME=Sanfrancisco&PRGNAME=MLSListingAgentDetail&ARGUMENTS=-N#{agent_id},-N167345231&from_List=Y")
      agent_data = Nokogiri::HTML.parse(@session.html).at_css('#Workspace')

      email_data = agent_data.search("[text()*='E-mail']").first.parent.parent.css('a').last
      email = email_data.text if email_data.present?
      return if email.blank?
      contact_data = agent_data.search("[text()*='Contact']").first.parent.parent.css('.mBlackText').last
      contact = contact_data.text if contact_data.present?

      fax_data = agent_data.search("[text()*='Fax']")
      fax = '1' + fax_data.first.parent.parent.css('.mBlackText').last.text.gsub('(', '').gsub(')', '').gsub('-', '').gsub(' ', '') if fax_data.present?

      lic_data = agent_data.search("[text()*='Lic:']")
      lic = lic_data.first.parent.parent.css('.mBlackText').last.text if lic_data.present?

      web_page_data = agent_data.search("[text()*='Web Page']")
      web_page = web_page_data.first.parent.parent.css('a').last.text if web_page_data.present?

      puts "#{full_name}, #{email}"
      agent = Agent.find_or_initialize_by(
        email: email,
        full_name: full_name,
        agent_type: 'better_way'
      )
      agent.first_name = first_name,
      agent.last_name = last_name,
      agent.phone = phone
      agent.office_name = office_name
      agent.fax = fax
      agent.lic = lic
      agent.contact = contact
      agent.web_page = web_page
      agent.address = address
      agent.country = country
      agent.save
    rescue Exception => error
        puts "--- error: #{error}"
    end
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
