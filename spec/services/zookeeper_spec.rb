# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  zookeeper libzookeeper cookbook-zookeeper
]

service = 'zookeeper'

def describe_package(package)
  describe package(package) do
    before do
      skip("#{package} is not installed, skipping...") unless package(package).installed?
    end

    it 'is expected to be installed' do
      expect(package(package).installed?).to be true
    end
  end
end

def describe_service(service)
  service_status = command("systemctl is-enabled #{service}").stdout.strip

  if service_status == 'enabled'
    describe_running_service(service)
  else
    describe_disabled_service(service)
  end
end

def describe_running_service(service)
  describe service(service) do
    it { should be_enabled }
    it { should be_running }
  end

  describe_port(2181)

  describe_consul_registration(service)
end

def describe_disabled_service(service)
  describe service(service) do
    it { should_not be_enabled }
    it { should_not be_running }
  end

  describe_port(2181)
end

def describe_port(port)
  describe port(port) do
    it { should be_listening }
  end
end

def describe_consul_registration(service)
  api_endpoint = 'http://localhost:8500/v1'
  service_json = command("curl -s #{api_endpoint}/catalog/service/#{service} | jq -r '.[]'").stdout
  health = command("curl -s #{api_endpoint}/health/service/#{service} | jq -r '.[].Checks[0].Status'").stdout.strip
  registered = JSON.parse(service_json).key?('Address') && health == 'passing' ? true : false

  describe 'Registered in consul' do
    it 'Should be registered and enabled' do
      expect(registered).to be true
    end
  end
end

describe "Checking #{service}..." do
  packages.each do |package|
    describe_package(package)
  end

  describe_service(service)

  describe_port(2181)

  describe_consul_registration(service)
end
