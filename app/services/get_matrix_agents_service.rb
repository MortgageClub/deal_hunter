require 'capybara'
require 'capybara/poltergeist'

class GetMatrixAgentsService
  def self.call
    set_up_crawler
    login
    go_to_matrix_search
  end

  private

  def self.login
    @session.visit("http://search.mlslistings.com/Matrix/Directory/Agent")
    @session.execute_script("$('#j_username').val('01972404')")
    @session.execute_script("$('#password').val('Blackdawn1')")
    @session.execute_script("$('#j_password').val('Blackdawn1')")
    @session.execute_script("$('#login').trigger('click')")
    sleep(10)
  end

  def self.go_to_matrix_search
    @session.click_link("m_ucSearchButtons_m_lbSearch")
    sleep(3)
    @session.select("100", :from => "m_ucDisplayPicker$m_ddlPageSize")
    sleep(3)

    page = 0
    while page < 50  do
      page += 1
      if page > 1
        @session.find("a[href=\"javascript:__doPostBack('m_DisplayCore','Redisplay|,#{(page-1)*100}')\"]", match: :first).click
        sleep(3)
      end
      puts "--- page: #{page}"
      parse_agents(@session.html)
    end
  end

  def self.parse_agents(html)
    data = Nokogiri::HTML.parse(html, nil, 'utf-8')
    data.css("#wrapperTable").each do |row|
      row_info = row.css('.d13m1')
      next if row_info.blank?

      full_name = row_info[1].children.text
      next if full_name.blank?
      email = row_info[7].children.attr('href').text.gsub('mailto:', '') if row_info[7].children.present?
      next if email.blank?
      first_name = full_name.split(' ').first
      last_name = full_name.split(' ').last

      broker_code = row_info[2].children.text
      office_name = row_info[3].children.text
      phone = '1' + row_info[4].children.text.gsub('(', '').gsub(')', '').gsub('-', '').gsub(' ', '') if !row_info[4].children.text.blank?
      fax = '1' + row_info[5].children.text.gsub('(', '').gsub(')', '').gsub('-', '').gsub(' ', '') if !row_info[5].children.text.blank?
      lic = row_info[6].children.text
      web_page = row_info[8].at_css('a').attr('href') if row_info[8].at_css('a').present?

      puts "#{full_name}, #{phone}, #{email}, #{office_name}, #{fax}, #{lic}, #{web_page}"
      agent = Agent.find_or_initialize_by(
        email: email,
        full_name: full_name,
        first_name: first_name,
        last_name: last_name,
        agent_type: 'matrix'
      )
      agent.broker_code = broker_code
      agent.phone = phone
      agent.office_name = office_name
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