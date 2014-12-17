module Proxy
  class ErrorLogging

    def initialize(logger)
      @logger = logger
    end

    ## * +puts+ must be called with a single argument that responds to +to_s+.
    def puts(str)
      @logger.error(str)
    end

    ## * +write+ must be called with a single argument that is a String.
    def write(str)
      @logger.error str
    end

    ## * +flush+ must be called without arguments and must be called
    ##   in order to make the logger appear for sure.
    def flush
    end

    ## * +close+ must never be called on the logger stream.
    def close(*args)
    end
  end
end