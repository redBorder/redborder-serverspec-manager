# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  redborder-chef-server cookbook-chef-server
]
describe 'Checking chef...' do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  describe service('chef-client') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/chef/client.rb') do
    it { should exist }
    it { should be_file }
  end

  describe port(4443) do
    it { should be_listening }
  end

  describe 'Registered in consul' do
    service_name = 'erchef'
    command = "curl -s http://localhost:8500/v1/catalog/service/#{service_name} | jq -r '.[].Address'"
    service_health = "curl -s http://localhost:8500/v1/health/service/#{service_name}"
    ips = command(command).stdout.split("\n")
    it 'Should be registered and enabled' do
      # expect(ips).not_to be_empty
      enabled = JSON.parse(service_health)[0]['Checks'][0]['Status'] == 'passing'
      expect(enabled).to be true
      puts "Output: #{ips}" if enabled
    end
  end
end
