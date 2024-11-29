# frozen_string_literal: true

require 'spec_helper'

describe 'Redborder Monitor Services' do
  describe service('redborder-monitor') do
    it { should be_running }
  end
end

describe 'Redborder Monitor Configurations' do
  describe file('/etc/redborder-monitor/config.json') do
    it { should exist }
  end

  describe command('rb_get_topics | grep monitor') do
    its(:stdout) { should match(/rb_monitor/) }
    its(:stdout) { should match(/rb_monitor_post/) }
  end
end

describe 'Logstash Configurations' do
  logstash_dir = '/etc/logstash/pipelines/monitor'

  %w[00_input.conf 01_monitor.conf 99_output.conf].each do |file_name|
    describe file("#{logstash_dir}/#{file_name}") do
      it { should exist }
    end
  end

  describe file('/etc/logstash/pipelines.yml') do
    it { should contain 'pipeline.id: monitor-pipeline' }
    it { should contain 'path.config: "/etc/logstash/pipelines/monitor"' }
  end
end

describe 'Druid Configurations' do
  describe file('/etc/druid/realtime/rb_realtime.spec') do
    it { should exist }
    its(:content) { should match(/"dataSource":\s*"rb_monitor"/) }
  end
end

describe 'Temporary Realtime Monitor Files' do
  describe command('ls /tmp/realtime/rb_monitor') do
    its(:exit_status) { should eq 0 }
  end
end

describe 'Kafka Data Consumption', fork: true do
  describe command('timeout 55 rb_consumer.sh -t rb_monitor_post') do
    its(:stdout) { should match(/"type":/) }
    its(:stdout) { should match(/"timestamp":/) }
    its(:stdout) { should match(/"sensor_name":/) }
    its(:stdout) { should match(/"monitor":/) }
  end
end
