# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  consul cookbook-consul
]

service = 'consul'
ports = [8300, 8301, 8302, 8500]
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

service_status = command("systemctl is-enabled #{service}").stdout
service_status = service_status.strip

describe "Checking #{service_status} service for #{service}..." do
  if service_status == 'enabled'
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end

    ports.each do |p|
      describe port(p) do
        it { should be_listening }
      end
    end

    # Use this block to test other services that need to be registered in consul
    describe "#{service} Registered in consul" do
      service_json_cluster = command("curl -s #{api_endpoint}/catalog/service/#{service} | jq -c 'group_by(.ID)[]'")
      service_json_cluster = service_json_cluster.stdout.chomp.split("\n")
      it "API response for #{service} should not be empty" do
        expect(service_json_cluster).not_to be_empty
      end
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

  if service_status == 'disabled'
    describe service(service) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

    ports.each do |p|
      describe port(p) do
        it { should_not be_listening }
      end
    end
  end
end
