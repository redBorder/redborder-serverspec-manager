# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'memcached'
service_status = command("systemctl is-enabled #{service}").stdout.strip

if service_status == 'enabled'
  describe 'Checking Memcached Service - Basic Checks' do
    # Verifies the installation of the Memcached package.
    describe package(service) do
      it { should be_installed }
    end

    # Checks the status of the Memcached service.
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end

    # Verifies the basic configuration of Memcached.
    describe 'Configuration' do
      describe file('/usr/lib/sysusers.d/memcached.conf') do
        it { should exist }
      end
    end

    # Check if Memcached is registered and healthy in Consul
    describe 'Registered in consul' do
      api_endpoint = 'http://localhost:8500/v1'
      service_json = command("curl -s #{api_endpoint}/catalog/service/#{service} | jq -r '.[]'").stdout
      health = command("curl -s #{api_endpoint}/health/service/#{service} | jq -r '.[].Checks[0].Status'").stdout.strip
      registered = JSON.parse(service_json).any? && health == 'passing'

      it 'Should be registered and healthy' do
        expect(registered).to be true
      end
    end
  end

  describe 'Checking Memcached Service - Advanced Checks' do
    # Checks network and connectivity aspects.
    describe 'Network and Connectivity' do
      describe port(11_211) do
        it { should be_listening }
      end
    end

    # Verifies the Memcached logs.
    describe 'Memcached Logs' do
      describe file('/var/log/memcached.log') do
        its(:content) { should_not match(/error/i) }
      end
    end

    # Verifies the user running the Memcached process.
    describe 'Process User' do
      describe command("ps aux | grep [m]emcached | awk '{print $1}'") do
        its(:stdout) { should match(/memcach\+/) }
      end
    end
  end
end

if service_status == 'disabled'
  describe 'Memcached Service Checks for Disabled Service' do
    describe service(service) do
      it 'should not be enabled' do
        expect(subject).not_to be_enabled
      end

      it 'should not be running' do
        expect(subject).not_to be_running
      end
    end
  end
end
