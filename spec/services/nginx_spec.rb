# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe 'Checking nginx' do
  describe package('nginx') do
    it { should be_installed }
  end

  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(443) do
    it { should be_listening }
  end

  describe 'Registered in consul' do
    service_json = command("curl -s http://localhost:8500/v1/catalog/service/nginx | jq -r '.[]'").stdout
    health = command("curl -s http://localhost:8500/v1/health/service/nginx | jq -r '.[].Checks[0].Status'").stdout
    health = health.strip
    registered = JSON.parse(service_json).key?('Address') && health == 'passing' ? true : false
    it do
      expect(registered).to be true
    end
  end
end
