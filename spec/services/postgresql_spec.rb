# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'postgresql'
port = 5432

databases = %w[bifrost druid monitors oc_id opscode_chef postgres radius redborder template0 template1]

def service_registered_and_healthy?(service)
  api_endpoint = 'http://localhost:8500/v1'
  service_json_cluster = command("curl -s #{api_endpoint}/catalog/service/#{service} | jq -c 'group_by(.ID)[]'")
  service_json_cluster = service_json_cluster.stdout.chomp.split("\n")
  health_cluster = command("curl -s #{api_endpoint}/health/service/#{service} | jq -r '.[].Checks[0].Status'")
  health_cluster = health_cluster.stdout.chomp.split("\n")
  service_and_health = service_json_cluster.zip(health_cluster)

  service_and_health.all? do |service_json, health|
    registered = JSON.parse(service_json)[0].key?('Address') && health == 'passing'
    registered # return the result of the check for this service/health pair
  end
end

describe 'Checking PostgreSQL Package...' do
  describe package(service) do
    it { should be_installed }
  end
end

service_status = command("systemctl is-enabled #{service}").stdout.strip

if service_status == 'enabled'
  describe "Checking #{service_status} service for #{service}..." do
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(port) do
      it { should be_listening }
    end

    it 'should be registered and healthy in Consul' do
      expect(service_registered_and_healthy?(service)).to be true
    end

    describe 'Database Connection' do
      describe command('psql -U redborder -d redborder -h localhost -c "\\l"') do
        databases.each do |db|
          its('stdout') { should match(/#{db}/) }
        end
        its('exit_status') { should eq 0 }
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

describe 'PostgreSQL Configuration Files' do
  describe file('/var/lib/pgsql/data/postgresql.conf') do
    it { should exist }
    it { should be_owned_by 'postgres' }
  end

  describe file('/var/lib/pgsql/data/pg_hba.conf') do
    it { should exist }
    it { should be_owned_by 'postgres' }
  end
end
