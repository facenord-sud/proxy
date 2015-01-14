require 'singleton'
class UriFromRake
  include Singleton

  attr_accessor :uri
end