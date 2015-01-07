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
require 'singleton'
require 'thread'

module Application
  def self.env?(environment)
    env = ENV['RACK_ENV'] || :dev
    env.downcase.to_sym == environment
  end

  def self.cache?
    ENV['PROXY_CACHE'].nil? or ENV['PROXY_CACHE'] == 'true' ? true : false
  end
end

require_all File.join(File.dirname(__FILE__), 'lib')