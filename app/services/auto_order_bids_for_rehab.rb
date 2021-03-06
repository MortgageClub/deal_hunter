require 'capybara'
require 'capybara/poltergeist'

class AutoOrderBidsForRehab
  attr_accessor :crawler, :listing

  def initialize(listing)
    @crawler = set_up_crawler
    @listing = listing
  end

  def call
    result = []

    login
    new_project
    close_crawler

    result
  end

  def login
    crawler.visit("https://www.buildzoom.com/user/sign_in")
    crawler.execute_script("$('#user_email').val('billytran1222@gmail.com')")
    crawler.execute_script("$('#user_password').val('huyhuy')")
    crawler.execute_script("$('.btn-block').trigger('click')")
    sleep(5)
  end

  def new_project
    is_error = false
    crawler.visit("https://www.buildzoom.com/project/new")
    sleep(3)

    begin
      crawler.find("#service_request_zipcode")
    rescue Exception => e
      is_error = true
    end

    if is_error
      new_project_js
    else
      new_project_form
      # close_crawler
      # raise Capybara::ElementNotFound
    end
  end

  def new_project_js
    #set project name
    crawler.execute_script("$('#service_request_title').val('Home remodel')")
    crawler.execute_script("$('#service_request_title').trigger('change')")
    crawler.execute_script("$('div.title-content button:last').trigger('click')")

    #select time
    crawler.execute_script("$('div.urgency-content div.answer-button[tabindex=4]').trigger('click')")

    #select bids
    crawler.execute_script("$('div.expected-responses-content div.answer-button[tabindex=9]').trigger('click')")

    #set address
    crawler.execute_script("$($('input.project-location')[0]).val('#{listing.address}, #{listing.city}')")
    crawler.execute_script("$($('input.project-location')[0]).trigger('change')")
    sleep(3)
    crawler.execute_script("$($('.uib-typeahead-match')[0]).trigger('click')")
    crawler.execute_script("$('div.location-content button:last').trigger('click')")

    #select square feet
    crawler.execute_script("$('div.job-site-content div.answer-button:nth(3)').trigger('click')")

    #select buget
    crawler.execute_script("$('#budget').val('string:5000-20000')")
    crawler.execute_script("$('#budget').trigger('change')")
    crawler.execute_script("$('div.budget-content button:last').trigger('click')")

    #set description
    crawler.execute_script("$($('div.description-content textarea')[0]).val('Hello, my name is Billy. I am looking for a professional to perform a total home remodel on a home that we recently purchased. The remodel will include interior and exterior paint, new laminate flooring, renovate bathrooms, renovate kitchen, and other miscellaneous items. \\nIf you are interested please contact me. Thanks.')")
    crawler.execute_script("$($('div.description-content textarea')[0]).trigger('change')")

    crawler.execute_script("$('div.description-content button:last').trigger('click')")
    sleep(1)
  end

  def new_project_form
    #set project name
    crawler.execute_script("$('#service_request_title').val('Home remodel')")
    crawler.execute_script("$('#service_request_title').trigger('change')")
    crawler.execute_script("$('#service_request_full_name').val('Billy Tran')")
    crawler.execute_script("$('#service_request_full_name').trigger('change')")
    crawler.execute_script("$('#project-form-submit').trigger('click')")
    sleep(3)

    #select time
    crawler.execute_script("$('#urgency').val('string:Within the next few weeks')")
    crawler.execute_script("$('#urgency').trigger('change')")

    #select buget
    crawler.execute_script("$('#budget').val('string:5000-20000')")
    crawler.execute_script("$('#budget').trigger('change')")

    #set address
    crawler.execute_script("$('#street_address').val('#{listing.address}, #{listing.city}')")
    crawler.execute_script("$('#street_address').trigger('change')")
    sleep(3)
    crawler.execute_script("$($('.uib-typeahead-match')[0]).trigger('click')")

    #select square feet
    crawler.execute_script("$('#square_footage').val('2000')")
    crawler.execute_script("$('#square_footage').trigger('change')")

    #set description
    crawler.execute_script("$('#description').val('Hello, my name is Billy. I am looking for a professional to perform a total home remodel on a home that we recently purchased. The remodel will include interior and exterior paint, new laminate flooring, renovate bathrooms, renovate kitchen, and other miscellaneous items. \nIf you are interested please contact me. Thanks.')")
    crawler.execute_script("$('#description').trigger('change')")

    #select bids
    crawler.execute_script("$('#expected_responses').val('number:4')")
    crawler.execute_script("$('#expected_responses').trigger('change')")

    crawler.execute_script("$('.project-submit-button:last').trigger('click')")
    sleep(1)
  end

  def set_up_crawler
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {
        js_errors: false, timeout: 60, phantomjs_options: ["--ignore-ssl-errors=yes", "--ssl-protocol=any"]
      })
    end
    Capybara.default_max_wait_time = 30
    Capybara::Session.new(:poltergeist)

    # crawler = Capybara::Session.new(:selenium)
    # crawler.driver.browser.manage.window.maximize
    # crawler
  end

  def close_crawler
    crawler.driver.quit
  end
end
