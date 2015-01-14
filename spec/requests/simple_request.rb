require 'spec_helper'

describe 'Request a site' do
 it "with GET at the URI: #{ENV['PROXY_TEST_URI']}" do
   RestClient.proxy = 'http://localhost:9292'
   response = RestClient.get ENV['PROXY_TEST_URI']
   expect(response.code).to satisfy {|value| value == 200 or value == 204 or value == 301 or value == 302}
 end
end