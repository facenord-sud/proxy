module Proxy
  class Cache
    include Proxy::Logging
    attr_reader :md5
    def initialize(env, uri)
      @env = env
      @uri = uri
      @md5 = Digest::MD5.hexdigest(uri.to_s)
      @redis = Redis.new
      @cache = @redis.get(@md5)
    end

    def cached?
      not @cache.nil? and not no_cache?
    end

    def get
      return nil if @cache.nil?
      redis_respone = JSON.parse(@cache)
      redis_headers = {}
      redis_respone['headers'].each {|key, value|
        next if key.downcase == 'status'
        redis_headers[key] = value.first}
      redis_body = [Base64.decode64(redis_respone['body'])]
      [redis_respone['status'], redis_headers, redis_body]
    end

    def save(status, headers, body)
      return if no_cache?
      body_to_save = body.to_s
      base_64 = false
      if  body_to_save.encoding != 'UTF-8'
        body_to_save = Base64.encode64(body_to_save)
        base_64 = true
      end
      redis_cache = {status: status, headers: headers, body: Base64.encode64(body.to_s), base_64: base_64}.to_json
      @redis.set(@md5, redis_cache)
    end

    private

    def no_cache?
      cache_control = @env['HTTP_CACHE_CONTROL']
      return false if cache_control.nil?
      cache_control.downcase!
      cache_control == 'max-age=0' or cache_control == 'no-cache' or cache_control == 'no-store' or @env['REQUEST_METHOD'].downcase != 'get'
    end
  end
end
