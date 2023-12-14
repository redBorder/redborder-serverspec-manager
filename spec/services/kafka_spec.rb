# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'kafka'
port = 9092
service_status = command("systemctl is-enabled #{service}").stdout.strip
api_endpoint = 'http://localhost:8500/v1'

packages = %w[cookbook-kafka confluent-kafka redborder-kafka librdkafka n2kafka rsyslog-kafka]

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
  end
end
