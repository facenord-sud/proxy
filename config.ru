require File.expand_path('adapter.rb')

file = File.new(File.join('logs', 'requests.log'), 'a+')
file.sync = true

use Rack::CommonLogger, file
run Adapter.new
