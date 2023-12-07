# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'druid-historical'
port = 8083

def service_registered_and_healthy?(service)
  api_endpoint = 'http://localhost:8500/v1'
  service_json = command("curl -s #{api_endpoint}/catalog/service/#{service} | jq -r '.[]'").stdout
  health = command("curl -s #{api_endpoint}/health/service/#{service} | jq -r '.[].Checks[0].Status'").stdout.strip
  JSON.parse(service_json).any? && health == 'passing'
end

service_status = command("systemctl is-enabled #{service}").stdout.strip

if service_status == 'enabled'
  describe 'Druid Historical Service Checks for Enabled Service' do
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(port) do
      it { should be_listening }
    end

    describe file('/usr/lib/druid/conf/druid/historical/jvm.config') do
      it { should exist }
    end

    it 'should be registered and healthy in Consul' do
      expect(service_registered_and_healthy?(service)).to be true
    end
  end
end

if service_status == 'disabled'
  describe 'Druid Historical Service Checks for Disabled Service' do
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

describe 'Checking Druid Historical Dependencies and Configuration' do
  %w[redborder-druid cookbook-druid druid java-1.8.0-openjdk].each do |pkg|
    describe package(pkg) do
      it "#{pkg} should be installed" do
        expect(subject).to be_installed
      end
    end
  end
end
