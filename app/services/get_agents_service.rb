require 'capybara'
require 'capybara/poltergeist'

class GetAgentsService
  include Capybara::DSL
  TD_COLUMN    = "td".freeze
  BLANK_SPACE  = "".freeze
  WHITE_SPACE  = " ".freeze

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
    user_id = "5002811"

    while data.css("#OuterTable").empty? && count < 5
      agent_info_url = "http://search.metrolist.net/LookUpWindow.aspx"\
        "?hidMLS=SACM&SID=72b7f77b-cffa-418c-8671-b55c803d029d&MLS=SACM&"\
        "URL=http%3A%2F%2Fprospector.metrolist.net%2Fscripts%2Fmgrqispi."\
        "dll%3FAPPNAME%3DMetrolist%26PRGNAME%3DMLSListingAgentDetail%26ARGUMENTS%3D-"\
        "N#{user_id}%2C-#{key}"\
        "%26openDetailInNewWindow%3Dtrue&showNavigation="
      @session.visit(agent_info_url)
      data = Nokogiri::HTML.parse(@session.html)
      byebug
      count += 1
      sleep(4)
    end

    # return [] if data.css(".subject-list-grid").empty?

    # data = Nokogiri::HTML.parse(@session.html)
    # result = []
    # table = data.css(".subject-list-grid")
    # table.css("tr").each do |tr|
    #   next if tr.css(TD_COLUMN).size < 2

    #   listing_id = tr.css(TD_COLUMN)[1].text
    #   home_type = tr.css(TD_COLUMN)[2].text.strip
    #   home_status = tr.css(TD_COLUMN)[3].text.strip.freeze
    #   address = tr.css(TD_COLUMN)[4].text
    #   city = tr.css(TD_COLUMN)[5].text.freeze
    #   zipcode = tr.css(TD_COLUMN)[6].text
    #   price = tr.css(TD_COLUMN)[7].text.gsub(/[^0-9\.]/, BLANK_SPACE).to_f
    #   bedroom = tr.css(TD_COLUMN)[8].text.to_i
    #   bathroom = tr.css(TD_COLUMN)[9].text
    #   dom_cdom = tr.css(TD_COLUMN)[10].text
    #   remark = tr.css(TD_COLUMN)[11].text.strip
    #   full_name = tr.css(TD_COLUMN)[12].text.strip
    #   first_name = full_name.split(WHITE_SPACE).first
    #   last_name = full_name.split(WHITE_SPACE).last
    #   agent_email = tr.css(TD_COLUMN)[13].text
    #   agent_phone = "1".freeze + tr.css(TD_COLUMN)[14].text.gsub("-".freeze, BLANK_SPACE)
    #   office_name = tr.css(TD_COLUMN)[15].text

    #   result << {
    #     listing_id: listing_id, price: price, address: address,
    #     city: city, zipcode: zipcode,
    #     home_type: home_type, home_status: home_status,
    #     bedroom: bedroom, bathroom: bathroom, dom_cdom: dom_cdom,
    #     remark: remark,
    #     agent: {
    #       full_name: full_name,
    #       first_name: first_name,
    #       last_name: last_name,
    #       phone: agent_phone,
    #       email: agent_email,
    #       office_name: office_name
    #     }
    #   }
    # end
    # result
  end

  def self.set_up_crawler
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {js_errors: false, timeout: 60})
    end
    @session = Capybara::Session.new(:poltergeist)
  end
end
