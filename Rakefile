# frozen_string_literal: true

desc 'Run KCL sample processor'
task :run do |_t|
  properties_file = ENV['properties_file']
  unless properties_file
    raise 'Properties file not provided. Use "rake run properties_file=<PATH_TO_FILE> to provide it."'
  end

  log_configuration = ENV['log_configuration']
  puts 'Running the Kinesis sample processing application...'

  command = "java -classpath amazon-kinesis-client-multilang  software.amazon.kinesis.multilang.MultiLangDaemon --properties-file #{properties_file}"
  command = "#{command} --log-configuration #{log_configuration}" if log_configuration
  sh command
end
