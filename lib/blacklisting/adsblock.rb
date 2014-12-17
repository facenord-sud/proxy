module Proxy
  class AdsBlock

    def initialize
      @blacklist = IO.readlines(File.join(File.dirname(__FILE__), 'blacklist.txt')).map {|line| line.chomp}
      raise Exception unless @blacklist.respond_to? :each
    end

    def block?(uri)
      @blacklist.each do |blacklisted|
        if uri.host =~ Regexp.new(blacklisted)
          return true
        end
      end
      false
    end
  end
end
