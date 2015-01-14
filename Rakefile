require File.join(File.dirname(__FILE__), 'spec', 'fixtures', 'uri_from_rake.rb')
begin
  require 'rspec/core/rake_task'
  namespace :spec do
    RSpec::Core::RakeTask.new(:simple_request, :uri) do |t, task_args|
      ENV['PROXY_TEST_URI'] = task_args[:uri]
      t.pattern = 'spec/requests/simple_request.rb'
    end

    RSpec::Core::RakeTask.new(:firefox, :uri) do |t, task_args|
      ENV['PROXY_TEST_URI'] = task_args[:uri]
      t.pattern = 'spec/requests/multiple_web_sites_spec.rb'
    end

    task :default => :spec

    # task :spec => :set_env
    #
    # task :set_env do
    #   ENV['uri']='-Xmx1g -XX:MaxPermSize=256m'
    # end
  end
  rescue LoadError
    # no rspec available
end

# namespace :spec do
#   desc 'Browse to a given URI through the proxy'
#   task :browse, :uri do |args|
#     puts 'hello'
#     require File.join(File.dirname(__FILE__), 'spec', 'spec_helper.rb')
#     describe 'browse to' do
#       it 'google' do
#         PROXY = 'localhost:9292'
#
#         profile = Selenium::WebDriver::Firefox::Profile.new
#         profile.proxy = Selenium::WebDriver::Proxy.new(
#             :http     => PROXY,
#             :ftp      => PROXY,
#             :ssl      => PROXY
#         )
#
#         driver = Selenium::WebDriver.for :firefox, :profile => profile
#         driver.get args[:uri]
#         ap driver.manage.get_log(:browser)
#       end
#     end
#   end
# end

namespace :logs do
  desc 'Start logstash with a correct configuration'
  task :logstash do
    conf = <<-EOF
    input {
      file {
        path => "#{File.expand_path(File.join('logs', 'logstash.log'))}"
        start_position => beginning
        codec => json {
          charset => "UTF-8"
        }
      }
    }

      output {
        elasticsearch {
          embedded => true
        }
        stdout { codec => rubydebug }
      }
EOF
    conf_name = 'config/logstash.conf'
    IO.write(conf_name, conf)

    sh "../logstash-1.4.2/bin/logstash -f #{File.expand_path(conf_name)}"
  end
end