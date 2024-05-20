# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  logstash redborder-logstash-plugins cookbook-logstash logstash-rules
]

service = 'logstash'
port = 9600
HOSTNAME = command('hostname -s').stdout.chomp

describe "Checking packages for #{service}..." do
  packages.each do |package|
    describe package(package) do
      before do
        skip("#{package} is not installed, skipping...") unless package(package).installed?
      end
      it 'is expected to be installed' do
        expect(package(package).installed?).to be true
      end
    end
  end
end

describe "Checking service status for #{service}..." do
  # Building conditions
  service_status = command("systemctl is-enabled #{service}").stdout.strip
  logstash_attr = command("knife node show #{HOSTNAME} --attribute default.redborder.logstash -F json").stdout.strip
  JSON.parse(logstash_attr)
  pipelines = logstash_attr['pipelines'] || [] # list of present pipelines

  if service_status == 'disabled' || pipelines.empty?
    describe service(service) do
      it { should_not be_enabled }
      it { should_not be_running }
    end
    describe port(port) do
      it { should_not be_listening }
    end
  elsif service_status == 'enabled'
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end
    describe port(port) do
      it { should be_listening }
    end
  else
    expect(false)
  end
end
