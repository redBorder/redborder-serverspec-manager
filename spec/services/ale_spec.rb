# frozen_string_literal: true

require 'spec_helper'
require 'set'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = pkg = 'redborder-ale'

describe "Checking packages for #{service}..." do
  describe package(pkg) do
    before do
      skip("#{pkg} is not installed, skipping...") unless package(pkg).installed?
    end

    it 'is expected to be installed' do
      expect(package(pkg).installed?).to be true
    end
  end
end

service_status = command("systemctl is-enabled #{service}").stdout.strip
describe "Checking #{service_status} service for #{service}..." do
  if service_status == 'enabled'
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end
  elsif service_status == 'disabled'
    describe service(service) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

    describe port(port) do
      it { should_not be_listening }
    end
  end
end

describe 'Redborder-ale is registered in consul' do
  if service_status == 'enabled'
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
        it 'Should be registered and enabled' do
          registered = JSON.parse(service)[0].key?('Address') && health == 'passing' # ? true : false
          expect(registered).to be true
        end
      end
    end
  end
end
