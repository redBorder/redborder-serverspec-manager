# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'webui'
port = 8001

service_status = command("systemctl is-enabled #{service}").stdout.strip

if service_status == 'enabled'
  describe 'Web UI Service Checks for Enabled Service' do
    describe service(service) do
      it 'should be enabled' do
        expect(subject).to be_enabled
      end

      it 'should be running' do
        expect(subject).to be_running
      end
    end

    describe port(port) do
      it 'should be listening' do
        expect(subject).to be_listening
      end
    end

    describe 'Registered in consul' do
      api_endpoint = 'http://localhost:8500/v1'
      service_json = command("curl -s #{api_endpoint}/catalog/service/#{service} | jq -r '.[]'").stdout
      health = command("curl -s #{api_endpoint}/health/service/#{service} | jq -r '.[].Checks[0].Status'").stdout
      health = health.strip
      registered = JSON.parse(service_json).key?('Address') && health == 'passing' ? true : false
      it 'Should be registered and enabled' do
        expect(registered).to be true
      end
    end
  end
end

if service_status == 'disabled'
  describe 'Web UI Service Checks for Disabled Service' do
    describe service(service) do
      it 'should not be enabled' do
        expect(subject).not_to be_enabled
      end

      it 'should not be running' do
        expect(subject).not_to be_running
      end
    end

    describe port(port) do
      it 'should not be listening' do
        expect(subject).not_to be_listening
      end
    end
  end
end

describe 'Web UI Configuration and Logs' do
  describe file('/etc/nginx/conf.d/webui.conf') do
    it 'should exist' do
      expect(subject).to exist
    end
  end

  describe file('/var/log/rb-rails/production.log') do
    it 'should exist' do
      expect(subject).to exist
    end
  end
end
