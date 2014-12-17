# All gems are included
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# Std lib to include by default
require 'uri'
require 'net/http'
require 'net/https'
require 'digest/md5'
require 'json'
require 'base64'
require 'logger'

require_all File.join(File.dirname(__FILE__), 'lib')

class Adapter
  include Proxy::Logging

  def call(env)
    load_all File.join(File.dirname(__FILE__), 'lib')
    env['rack.errors'] = Proxy::ErrorLogging.new(logger)
    Proxy::RequestHandler.new.call(env)
  end
end
