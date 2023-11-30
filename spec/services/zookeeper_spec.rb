# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe service('zookeeper') do
  describe package('zookeeper') do
    it { should be_installed }
  end
  it { should be_enabled }
  it { should be_running }

  describe port(2181) do
    it { should be_listening }
  end
end

describe 'Registered in consul' do
  service_name = 'zookeeper'
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
