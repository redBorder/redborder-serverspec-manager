# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'sfacctd'
port = 6343
health_port = 7984
config_file = '/etc/sfacctd/config.json'
service_status = command("systemctl is-enabled #{service}").stdout.strip

packages = %w[cookbook-pmacct redborder-sfacctd x2kafka]

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

if service_status == 'enabled'
  describe "Checking #{service_status} service for #{service}..." do
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(port) do
      it { should be_listening }
    end

    # the unit in /etc overrides the sfacctd.service of the pmacct package
    describe file('/etc/systemd/system/sfacctd.service') do
      it { should exist }
    end

    describe command("systemctl show -p ExecStart --value #{service}") do
      its(:stdout) { should include "/usr/bin/x2kafka #{config_file}" }
    end

    describe file(config_file) do
      it { should exist }
      its(:content) { should match(/"proto":\s*"sflow"/) }
      its(:content) { should match(/"topic":\s*"rb_flow"/) }
    end

    describe port(health_port) do
      it { should be_listening }
    end

    describe command("curl -s http://localhost:#{health_port}/health") do
      its(:stdout) { should match(/"status":\s*"ok"/) }
    end
  end
end

if service_status == 'disabled'
  describe "Checking #{service_status} service for #{service}..." do
    describe service(service) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

    describe port(port) do
      it { should_not be_listening }
    end

    describe port(health_port) do
      it { should_not be_listening }
    end
  end
end
