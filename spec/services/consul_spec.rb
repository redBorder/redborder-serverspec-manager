# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  consul cookbook-consul
]

describe 'Checking consul' do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  describe service('consul') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8300) do
    it { should be_listening }
  end

  describe 'Registered in consul' do
    service_json = command("curl -s http://localhost:8500/v1/catalog/service/erchef | jq -r '.[]'").stdout
    health = command("curl -s http://localhost:8500/v1/health/service/erchef | jq -r '.[].Checks[0].Status'").stdout
    health = health.strip
    registered = JSON.parse(service_json).key?('Address') && health == 'passing' ? true : false
    it do
      expect(registered).to be true
    end
  end
end
