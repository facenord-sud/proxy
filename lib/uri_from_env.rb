class UriFromEnv
  attr_accessor :scheme, :host, :port, :path, :query, :fragment

  def initialize(env)
    if env['REQUEST_URI'].nil?
      @scheme = env['rack.url_scheme']
      @host = env['SERVER_NAME']
      @port = env['SERVER_PORT'].nil? ? '80' : env['SERVER_PORT']
      @path = env['PATH_INFO']
      @query = env['QUERY_STRING']
      @fragment = nil
    else
      uri = URI.parse(env['REQUEST_URI'])
      @scheme = uri.scheme
      @host = uri.host
      @port = uri.port
      @path = uri.path
      @query = uri.query
      @fragment = uri.fragment
    end
  end

  def print_url_part(value, symbol)
    if value.nil? or value == ''
      ''
    else
       symbol + value
    end
  end

  def print_port
    if @port.to_s == '80'
      ''
    else
      ':' + @port
    end
  end

  def to_s
    "#{@scheme}://#{@host}#{print_port}#{@path}#{print_url_part @query, '?'}#{print_url_part @fragment, '#'}"
  end
end