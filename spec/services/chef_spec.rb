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
end

describe 'Registered in consul and enabled' do
  service_name = 'erchef'
  response = "curl -s http://localhost:8500/v1/catalog/service/#{service_name} | jq -r '.[].Address'"
  health = "curl -s http://localhost:8500/v1/health/service/#{service_name} | jq -r '.[].Checks' | jq -r '.[].Status'"
  service_health = command(health).stdout.split("\n")
  ips = command(response).stdout.split("\n")
  it 'Should be registered and enabled' do
    expect(ips).not_to be_empty
    passing_checks = service_health.to_s.chomp
    expect(passing_checks).to include('passing')
  end
end
