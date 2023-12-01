# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  redborder-postgresql postgresql
]

describe 'Cheking redborder-postgresql' do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  describe service('postgresql') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(5432) do
    it { should be_listening }
  end

  describe 'Registered in consul' do
    api_url = 'http://localhost:8500/v1'
    service = 'postgresql'
    service_json = command("curl -s #{api_url}/catalog/service/#{service} | jq -r '.[]'").stdout
    health = command("curl -s #{api_url}/health/service/#{service} | jq -r '.[].Checks[0].Status'").stdout
    health = health.strip
    registered = JSON.parse(service_json).key?('Address') && health == 'passing' ? true : false
    it do
      expect(registered).to be true
    end
  end
end
