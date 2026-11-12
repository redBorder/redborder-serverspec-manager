# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'f2k'
port = 2055
health_port = 7983
config_file = '/etc/f2k/config.json'
service_status = command("systemctl is-enabled #{service}").stdout.strip
api_endpoint = 'http://localhost:8500/v1'

packages = %w[cookbook-f2k redborder-f2k x2kafka]

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

    describe command("systemctl show -p ExecStart --value #{service}") do
      its(:stdout) { should include "/usr/bin/x2kafka #{config_file}" }
    end

    describe file(config_file) do
      it { should exist }
      its(:content) { should match(/"proto":\s*"netflow"/) }
    end

    describe port(health_port) do
      it { should be_listening }
    end

    describe command("curl -s http://localhost:#{health_port}/health") do
      its(:stdout) { should match(/"status":\s*"ok"/) }
    end

    describe 'Registered in consul' do
      service_json_cluster = command("curl -s #{api_endpoint}/catalog/service/#{service} | jq -c 'group_by(.ID)[]'")
      service_json_cluster = service_json_cluster.stdout.chomp.split("\n")
      health_cluster = command("curl -s #{api_endpoint}/health/service/#{service} | jq -r '.[].Checks[0].Status'")
      health_cluster = health_cluster.stdout.chomp.split("\n")
      service_and_health = service_json_cluster.zip(health_cluster)
      service_and_health.each do |service, health|
        registered = JSON.parse(service)[0].key?('Address') && health == 'passing' # ? true : false
        it 'Should be registered and enabled' do
          expect(registered).to be true
        end
      end
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
