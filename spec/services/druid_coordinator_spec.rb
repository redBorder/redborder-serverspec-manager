# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  redborder-druid cookbook-druid druid
]
service = 'druid-coordinator'
describe "Checking #{service}" do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  describe service(service) do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8084) do
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
end
