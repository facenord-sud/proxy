require File.join(File.dirname(__FILE__), 'application.rb')
class Adapter
  include Proxy::Logging

  def call(env)
    begin
     logger.level = Logger::ERROR if Application.env? :production
      logger.start_request
      if Application.env? :dev or Application.env? :test
        load File.join(File.dirname(__FILE__), 'application.rb')
        load_all File.join(File.dirname(__FILE__), 'lib')
      end
      env['rack.errors'] = Proxy::ErrorLogging.new(logger)
      env['proxy.logger_id'] = logger.__id__
      Proxy::RequestHandler.new.call(env)
    ensure
      logger.end_request
    end
  end
end
