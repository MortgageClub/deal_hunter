require 'capybara/poltergeist'

module ZillowService
  class UpdatePropertyTax
    ATTEMPTS = 4

    def self.call(property_id)
      property = Property.find(property_id)
      zpid = GetZpid.call(property.address.street_address, property.address.zip)

      if zpid && property_tax = get_property_tax(zpid)
        property.update(estimated_property_tax: property_tax)
      end
    end

    private

    #data.css('#hdp-tax-history table tbody td')[0]
    #<td>2014</td>
    #data.css('#hdp-tax-history table tbody td')[1]
    #<td class="numeric">$5,813<span class="zsg-lg-hide"><span class="delta-value"><span class="inc">+15.6%</span></span></span></td>
    def self.get_property_tax(zpid)
      return unless data = scraping_data_from_zillow(zpid)
      return unless data.css('#hdp-tax-history table tbody td')[0]
      return unless data.css('#hdp-tax-history table tbody td')[1]

      year = data.css('#hdp-tax-history table tbody td')[0].text
      property_tax_text = data.css('#hdp-tax-history table tbody td')[1].text

      if property_tax_text.include? '-'
        property_tax = property_tax_text.split('-').first
      elsif property_tax_text.include? '+'
        property_tax = property_tax_text.split('+').first
      end
      BigDecimal.new(property_tax.gsub(/[^0-9\.]/,''))
    end

    def self.scraping_data_from_zillow(zpid)
      #www.zillow.com/homes/19709750_zpid/
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, {js_errors: false})
      end
      browser = Capybara::Session.new(:poltergeist)
      browser.visit "http://www.zillow.com/homes/" + zpid + "_zpid"
      browser.find('h2', text: "Price / Tax History").click
      data = Nokogiri::HTML.parse(browser.html)
      number_of_tries = 0

      while (tax_table = data.css('#hdp-tax-history table')).empty?
        browser.find('h2', text: "Price / Tax History").click
        data = Nokogiri::HTML.parse(browser.html)
        number_of_tries += 1
        break if number_of_tries > ATTEMPTS
        sleep(5)
      end
      tax_table.empty? ? nil : data
    end
  end
end
