# frozen_string_literal: true

require 'spec_helper'
require 'set'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = serv_consul = 'redborder-ale'
package = 'redborder-ale'
port = 7779

API_ENDPOINT = 'http://localhost:8500/v1'

describe "Checking packages for #{service}..." do
  describe package(package) do
    before do
      skip("#{package} is not installed, skipping...") unless package(package).installed?
    end

    it 'is expected to be installed' do
      expect(package(package).installed?).to be true
    end
  end
end

service_status = command("systemctl is-enabled #{service}").stdout.strip
describe "Checking #{service_status} service for #{service}..." do
  describe service(service) do
    if service_status == 'enabled'
      it { should be_enabled }
      it { should be_running }
      describe port(port) do
        it { should be_listening }
      end

      describe 'Registered in consul' do
        service_json_cluster = command("curl -s #{API_ENDPOINT}/catalog/service/#{serv_consul} | jq -c 'group_by(.ID)[]'")
        service_json_cluster = service_json_cluster.stdout.chomp.split("\n")
        health_cluster = command("curl -s #{API_ENDPOINT}/health/service/#{serv_consul} | jq -r '.[].Checks[0].Status'")
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
end

# describe 'Redborder-ale is using correct ruby setup' do
    # describe command('sudo -u redborder-ale which ruby') do
    #   its(:stdout) { should match %r{/usr/lib/rvm/rubies/ruby-2.7.5/bin/ruby} }
    # end
# end
