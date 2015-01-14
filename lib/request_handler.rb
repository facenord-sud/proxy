module Proxy
  class RequestHandler
    include Proxy::Logging

    def initialize
      @ads_block = Proxy::AdsBlock.new
      @connection = HTTPClient.new
    end

    def call(env)
      uri = UriFromEnv.new(env)
      log "Started #{env['REQUEST_METHOD']} request on #{uri}", env
      cache = Proxy::Cache.new(env, uri) if Application.cache?

      if @ads_block.block? uri
        log 'Request blacklisted', env
        response_rack = error_403
      elsif Application.cache? and cache.cached?
        log 'Serving a redis cached response', env
        response_rack = cache.get
      else
        log 'Will request the server', env
        response_rack = request_server env, uri
        cache.save(*response_rack) if Application.cache?
      end
      response_rack
    end

    def request_server(env, uri)
      source_request = Rack::Request.new(env)
      content_type = source_request.content_type
      # target_request = Net::HTTP.const_get(env['REQUEST_METHOD'].capitalize).new(uri.to_s)

      # target_request.initialize_http_header(extract_http_headers(env))
      body = nil
      if source_request.body
        source_request.body.rewind
        body = source_request.body
      end

      headers = extract_http_headers(env)
      headers['Content-Length'] = env['CONTENT_LENGTH'] || 0
      headers['Content-Type'] = content_type if content_type

      to_server = @connection.request_async(env['REQUEST_METHOD'], uri.to_s, nil, body, headers).pop

      log "The request to the server is prepared with the following headers: \n" + headers.map {|k, v| "#{k}: #{v}"}.join("\n") + "\n"
      response_headers = to_server.headers
      log("From URI: #{env['REQUEST_METHOD']} #{uri} #{to_server.status}")
      response_headers.delete('Transfer-Encoding')
      response_headers.delete('Status')
      response_headers.delete('Content-Length') if to_server.status == 204
      if Application.env? :production
        logstash(
            "#{to_server.status} #{env['REQUEST_METHOD']} #{uri}",
            { rack_env: env,
             request_headers: headers,
             response_headers: response_headers,
             status: to_server.status,
             verb: env['REQUEST_METHOD'],
             uri: uri.to_s }
        )
      end
      [to_server.status, response_headers, to_server.body]
    end

    def extract_http_headers(env)
      headers = {}
      env.select do |k,v|
        k.start_with? 'HTTP_'
      end.each do |pair|
          next if pair[0] == 'HTTP_PROXY_CONNECTION' or pair[0] == 'HTTP_CONNECTION' or pair[0] == 'HTTP_HOST'
          headers[pair[0].gsub(/^HTTP_/, '').split('_').map { |element| element.downcase.capitalize }.join('-')] = pair[1]
      end
      # headers.delete('PROXY_CONNECTION')
      # headers.delete('CONNECTION')
      # headers.delete('HOST')
      # headers.map do |header|
      #   header[0].split('_').map { |element| element.downcase.capitalize }.join('-')
      # end
      headers
    end

    def error_403
      ['403', {'Content-type' => 'text/html'}, ['Blocked by proxy']]
    end
  end
end
