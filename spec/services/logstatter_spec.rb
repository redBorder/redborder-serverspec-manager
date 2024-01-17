# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'rb-logstatter'
service_status = command("systemctl is-enabled #{service}").stdout.strip
packages = %w[
  cookbook-rb-logstatter rb-logstatter
]

describe "Checking #{packages}" do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end
end

describe 'Checking service' do
  if service_status == 'enabled'
    describe "Checking #{service_status} service for #{service}..." do
      describe service(service) do
        it { should be_enabled }
        it { should be_running }
      end
    end
    describe 'Process User' do
      describe command("ps aux | grep logstatter | awk '{print $1}'") do
        its(:stdout) { should match(/logstat\+/) }
      end
    end
  end

  if service_status == 'disabled'
    describe "Checking #{service_status} service for #{service}..." do
      describe service(service) do
        it { should_not be_enabled }
        it { should_not be_running }
      end
    end
  end
end

describe 'Checking config' do
  describe 'Configuration' do
    describe file('/etc/logstatter/logstatter.conf') do
      it { should exist }
    end
  end
end
