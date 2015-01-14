
ENV['RACK_ENV'] = 'test'
ENV['PROXY_CACHE'] = 'false'
require File.join(File.dirname(__FILE__), '..',  'adapter.rb')

require_all File.join(File.dirname(__FILE__), 'fixtures')


module RSpecMixin
  include Rack::Test::Methods
  def app
    @app ||= Adapter.new
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
end