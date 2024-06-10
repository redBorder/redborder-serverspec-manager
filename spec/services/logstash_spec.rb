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
PIPELINES_PATH = '/etc/logstash/pipelines.yml'

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
  service_status = command("systemctl is-enabled #{service}").stdout.strip
  regex = '"^- pipeline\.id: .*-pipeline$"'
  has_pipelines = command("grep --perl-regex -q '#{regex}' #{PIPELINES_PATH}").stdout

  if service_status == 'disabled' || !has_pipelines
    describe service(service) do
      it { should_not be_enabled }
      it { should_not be_running }
    end
    describe port(port) do
      it { should_not be_listening }
    end
  end

  if service_status == 'enabled'
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end
    describe port(port) do
      it { should be_listening }
    end
  end
end
