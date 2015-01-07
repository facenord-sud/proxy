class LoggingCaller
  include Proxy::Logging

  attr_accessor :logger_test
  def initialize
    @logger_test = logger
  end
end