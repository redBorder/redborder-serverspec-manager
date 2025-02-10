# frozen_string_literal: true

require 'spec_helper'
require 'set'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = serv_consul = pkg = 'redborder-llm'
CONSUL_API_ENDPOINT = 'http://localhost:8500/v1'
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

    describe 'Registered in consul' do
      catalog_cmd = "curl -s #{CONSUL_API_ENDPOINT}/catalog/service/#{serv_consul} | jq -c 'group_by(.ID)[]'"
      service_json_cluster = command(catalog_cmd)
      service_json_cluster = service_json_cluster.stdout.chomp.split("\n")
      health_cmd = "curl -s #{CONSUL_API_ENDPOINT}/health/service/#{serv_consul} | jq -r '.[].Checks[0].Status'"
      health_cluster = command(health_cmd)
      health_cluster = health_cluster.stdout.chomp.split("\n")
      it 'Should be at least in one node' do
        # expect(service_json_cluster.size).to be > 0 # redundant check
        expect(health_cluster.size).to be > 0
      end
      service_and_health = service_json_cluster.zip(health_cluster)
      service_and_health.each do |service, health|
        registered = JSON.parse(service)[0].key?('Address') && health == 'passing' # ? true : false
        it 'Should be registered and enabled' do
          expect(registered).to be true
        end
      end
    end

    describe 'Checking consul sync address' do
      hostname = command('hostname').stdout.strip.split('.')[0]
      param = 'ipaddress_sync'
      sync_address = command("knife node show #{hostname} -l --attr #{param} | awk '/#{param}:/ {print $2}'")
      ip_address = command("curl -s #{CONSUL_API_ENDPOINT}/catalog/service/#{serv_consul} | jq -r '.[0].Address'")
      sync_address = sync_address.stdout.strip
      ip_address = ip_address.stdout.strip
      it 'should match sync address' do
        expect(ip_address).to eq(sync_address)
      end
    end

  elsif service_status == 'disabled'
    describe service(service) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

    it 'Should be registered and enabled' do
      registered = JSON.parse(service)[0].key?('Address') && health == 'passing' # ? true : false
      expect(registered).to be true
    end
  end
end
