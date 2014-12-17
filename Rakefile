namespace :logs do
  desc 'Start logstash with a correct configuration'
  task :logstash do
    conf = <<-EOF
    input {
      file {
        path => "#{File.expand_path(File.join('logs', 'app.log'))}"
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

    sh "logstash-1.4.2/bin/logstash -f #{File.expand_path(conf_name)}"
  end
end