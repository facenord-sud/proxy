require 'spec_helper'

describe 'Browse through a lot of WebSites and show error pages' do
  it "browse to #{ENV['PROXY_TEST_URI']}" do
    uri = ENV['PROXY_TEST_URI']
    PROXY = 'localhost:9292'

    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.proxy = Selenium::WebDriver::Proxy.new(
        :http     => PROXY,
        :ftp      => PROXY,
        :ssl      => PROXY
    )

    profile.add_extension(File.dirname(__FILE__) + '/../fixtures/firebug-2.0.7.xpi')

    driver = Selenium::WebDriver.for :firefox, :profile => profile
    driver.get(uri)
    # puts(driver.manage.get_log(:browser).map do |log|
    #   log.message
    #      end.join(''))
    #driver.quit
  end
end
