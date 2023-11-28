require 'spec_helper'
require 'json'
require_relative './helper/kafka_data'

set :backend, :ssh

kafka_topic = 'rb_flow'
sample_json = KafkaData.get_sample_data
services = %w(f2k logstash kafka)
plugins = %w(macscrambling geoip macvendor darklist netflowenrich)

services.each do |servicio|
  describe service("#{servicio}") do
    it { should be_enabled }
    it { should be_running }
  end
end

#check for Netflow data
describe command('timeout 5s tcpdump -i any port 2055') do
    its(:stdout) { should_not be_empty}
end

# Check if f2k is running on port 2055
describe 'f2k' do
  it 'should be running and listening on port 2055' do
    expect(port(2055)).to be_listening

    command_output = command('netstat -tulpn | grep f2k').stdout
    # Check for any IP with port 2055
    expect(command_output).to match(/\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}(?::2055)?\b/)
    # Check for PID and name of program 
    expect(command_output).to match(/(\d+)\/f2k/)
  end
end

# Test to check if Kafka topic exists
describe command("rb_get_topics | grep -q #{kafka_topic}") do
  its(:exit_status) { should eq 0 }
end
  
# Test to check if data is produced to the Kafka topic
describe command("echo '#{sample_json}' | rb_producer.sh -t #{kafka_topic}") do
  its(:exit_status) { should eq 0 }
end
  
# Test to check if the Kafka consumer receives the message within the timeout
describe command("kafka-console-consumer --bootstrap-server #{ENV['TARGET_HOST']}:9092 --new-consumer --topic rb_flow --from-beginning --timeout-ms 2000 | grep '#{KafkaData.get_mac_address}'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain "#{sample_json}"}
end

# Test if pipeline exist
describe file('/etc/logstash/pipelines.yml') do
  it { should exist }
  its(:content) { should match /- pipeline.id: netflow-pipeline/}
  its(:content) { should_not match /#.*- pipeline\.id: netflow-pipeline/}
end

# Test if netflow pipeline is running
describe 'Test if logstash pipeline (netflow) is running' do
    it 'checks pipeline stats' do
      command_result = command("curl -XGET #{ENV['HOSTNAME']}:9600/_node/stats/pipelines?pretty")
      
      json_response = JSON.parse(command_result.stdout)
      expect(json_response['status']).to eq('green')

      expect(json_response['pipelines']).to include('netflow-pipeline')
    end
end

# Test if logstash plugins exist
describe command('/usr/share/logstash/bin/logstash-plugin list') do
  it 'checks if plugins exist' do
    plugins.each do |plugin|
      expect(subject.stdout).to match(/logstash-filter-#{Regexp.escape(plugin)}/)
    end
  end
end

# # Test if netflow pipeline has functioning input/filter/ouput
# describe 'Test if logstash pipeline is functioning' do
#   it 'checks pipeline plugins' do
#     logstash_result = command('curl -XGET localhost:9600/_node/stats/pipelines?pretty')
#     logstash_response = JSON.parse(logstash_result.stdout)
    
#     pipeline = logstash_response['pipelines']['netflow-pipeline']['plugins']
#     expect(pipeline['inputs']['name']).to contain 'kafka'
#   end
# end