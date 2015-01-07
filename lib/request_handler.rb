module Proxy
  class RequestHandler
    include Proxy::Logging

    def initialize
      @ads_block = Proxy::AdsBlock.new
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
      target_request = Net::HTTP.const_get(env['REQUEST_METHOD'].capitalize).new(uri.to_s)

      target_request.initialize_http_header(extract_http_headers(env))
      if target_request.request_body_permitted? && source_request.body
        source_request.body.rewind
        target_request.body_stream = source_request.body
      end

      target_request.content_length = env['CONTENT_LENGTH'] || 0
      target_request.content_type = content_type if content_type
      log 'The request to the server is prepared with the following headers: ' + {extracted_http: extract_http_headers(env), server_verb: env['REQUEST_METHOD'].upcase, server_uri: uri.to_s}.awesome_inspect
      to_server = Rack::HttpStreamingResponse.new(target_request, uri.host, uri.port)
      to_server.use_ssl = (uri.scheme == 'https')
      response_headers = to_server.headers
      log("From URI: #{env['REQUEST_METHOD']} #{uri} #{to_server.status}")
      response_headers.delete('transfer-encoding')
      response_headers.delete('status')
      response_headers.delete('content-length') if to_server.status == 204
      [to_server.status, response_headers, to_server.body]
    end

    def extract_http_headers(env)
      headers = {}
      env.select {|k,v| k.start_with? 'HTTP_'}
        .each {|pair| headers[pair[0].gsub(/^HTTP_/, '')] = pair[1]}
      headers.delete('PROXY_CONNECTION')
      headers.delete('CONNECTION')
      headers.delete('HOST')
      headers
    end

    def error_403
      ['403', {'Content-type' => 'text/html'}, ['Blocked by proxy']]
    end
  end
end
