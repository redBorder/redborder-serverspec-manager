# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  redborder-chef-server cookbook-chef-server
]

service = 'chef-client'
config_file = '/etc/chef/client.rb'
port = 4443
serv_consul = 'erchef'
api_endpoint = 'http://localhost:8500/v1'

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

describe "Checking service_status for #{service}..." do
  describe service(service) do
    it { should be_enabled }
    it { should be_running }
  end

  describe file(config_file) do
    it { should exist }
    it { should be_file }
  end

  describe port(port) do
    it { should be_listening }
  end

  describe 'Registered in consul' do
    service_json_cluster = command("curl -s #{api_endpoint}/catalog/service/#{serv_consul} | jq -c 'group_by(.ID)[]'")
    service_json_cluster = service_json_cluster.stdout.chomp.split("\n")
    health_cluster = command("curl -s #{api_endpoint}/health/service/#{serv_consul} | jq -r '.[].Checks[0].Status'")
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
