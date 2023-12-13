# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  redborder-druid cookbook-druid druid
]
service_in_consul = 'druid-coordinator'
api_endpoint = 'http://localhost:8500/v1'

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
