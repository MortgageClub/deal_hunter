require 'mechanize'

class CrawlerService

  def self.call
    get_data
  end

  private

  def self.get_data
    # init Mechanize agent
    agent = Mechanize.new
    agent.user_agent_alias = 'Windows Chrome'

    home_page = login(agent)
    p home_page
    metrolist_page = go_to_metro_list(home_page, agent)

    session_id = metrolist_page.uri.to_s.split("&SID=").last
    p session_id
    metrolist = agent.get("http://search.metrolist.net/ListingGridDisplay.aspx?hidMLS=SACM&GRID=137130&PTYPE=RESI&SRC=HS&SRID=211618742&PRINT=0&SAS=0&ARCH=0&HIDD=0&REMO=0&SNAME=Sacramento+Hotsheet&CARTID=&SPLISTINGRID=0&STYPE=HS&SID=#{session_id}")
  end



  def self.go_to_metro_list(home_page, agent)
    metrolist_link = home_page.link_with(:id => "MainContent_OtherMLS1_rpOtherApplications_SACM_3")
    continue_page = metrolist_link.click
    page = agent.get("http://qtrosso.rapmls.com/sp/startSSO.ping?PartnerIdpId=MLSListingsIdentityProvider&TargetResource=http://login.rapmls.com/SACM/','SACM'")
    page_form = page.form
    resume_button = page_form.button_with(value: "Resume")
    continue_page = agent.submit(page_form, resume_button)
    continue_form = continue_page.form
    continue_button = continue_form.button_with(value: "Continue")
    continue_page = agent.submit(continue_form, continue_button)
    continue_form = continue_page.form
    continue_button = continue_form.button_with(value: "Continue")
    result = agent.submit(continue_form, continue_button)
  end

  def self.login(agent)
    home_url = "http://reil.com/"
    home_page = agent.get(home_url)
    form = home_page.form
    button = form.button_with(id: "MainContent_UCLogin_ibtnSignIn")
    continue_page = agent.submit(form, button)

    continue_form = continue_page.form
    continue_button = continue_form.button_with(value: "Continue")
    login_page = agent.submit(continue_form, continue_button)

    login_form = login_page.form
    username_field = login_form.field_with(name: "j_username")
    password_field = login_form.field_with(name: "password")
    password__hide_field = login_form.field_with(name: "j_password")
    username_field.value = '01972404'
    password_field.value = 'Blackdawn1'
    password__hide_field.value = 'Blackdawn1'
    login_button = login_form.button_with(id: "login")
    continue_page = agent.submit(login_form, login_button)

    continue_form = continue_page.form
    continue_button = continue_form.button_with(value: "Continue")
    continue_page = agent.submit(continue_form, continue_button)
    continue_link = continue_page.link_with(:text => "continue")
    home_page = continue_link.click
    home_page
  end

end