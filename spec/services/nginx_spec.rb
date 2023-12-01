# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  nginx cookbook-nginx
]

service = 'nginx'

describe "Checking #{service}..." do
  packages.each do |package|
    describe package(package) do
      before do
        unless package(package).installed?
          skip("#{package} is not installed, skipping...")
        end
      end

      it 'is expected to be installed' do
        expect(package(package).installed?).to be true
      end
    end
  end

  service_status = command("systemctl is-enabled #{service}").stdout
  service_status = service_status.strip

  if service_status == 'enabled'
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(443) do
      it { should be_listening }
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
  else # if service disabled
    describe service(service) do
      it { should_not be_enabled }
      it { should_not be_running }
    end
  
    describe port(8300) do
      it { should_not be_listening }
    end
  end
end
