module Proxy
  module Logging
    class SimpleLogger < Logger
      def initialize
        file = File.new(File.join('logs', 'app.log'), File::WRONLY | File::APPEND | File::CREAT)
        file.sync = true
        super(file)
      end
    end

    def logger
      @simple_logger ||= LogStashLogger.new(type: :file, path: 'logs/app.log', sync: true)
    end

    def log(message, env)
      logstash = {}
      logstash[:message] = message
      logstash.merge! env
      logger.debug(logstash)
    end
  end
end