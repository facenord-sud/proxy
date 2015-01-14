module Proxy
  module Logging
    class SimpleLogger < Logger
      include Singleton
      def initialize
        file = File.new(File.join('logs', 'app.log'), File::WRONLY | File::APPEND | File::CREAT)
        file.sync = true
        @IO = MultiIO.new(STDOUT, file)
        super(@IO)
      end

      def start_request
        @IO.new_request
      end

      def end_request
        @IO.print_logs
      end
    end

    class MultiIO
      attr_accessor :logs_per_request

      def initialize(*targets)
        @targets = targets
        @mutex = Mutex.new
      end

      def new_request
      end

      def print_logs
        current_request_id = request_id
        Thread.new {
          @mutex.synchronize {
            @targets.each do |t|
              LogMessages.instance.messages.delete(current_request_id).each { |args| t.write(*args)}
              t.write "\n"
            end
          }
        }
      end

      def write(*args)
        LogMessages.instance.add(request_id, args)
      end

      def close
        @targets.each(&:close)
      end

      def request_id
        Thread.current.__id__
      end
    end

    class LogMessages
      include Singleton

      attr_accessor :messages

      def initialize
        @messages = {}
      end

      def add(key, args)
        @messages[key] = [] if @messages[key].nil?
        @messages[key] << args
      end
    end

    def logger
      @simple_logger ||= SimpleLogger.instance#LogStashLogger.new(type: :file, path: 'logs/app.log', sync: true)
    end

    def log(message, env = nil)
      # logstash = {}
      # logstash[:message] = message
      # logstash.merge! env
      logger.debug(message)
    end

    def logstash(message, params)
      @logstash ||= LogStashLogger.new(type: :file, path: 'logs/logstash.log', sync: true)
      event = {}
      event[:message] = message
      @logstash.info(event.merge params)
    end
  end
end