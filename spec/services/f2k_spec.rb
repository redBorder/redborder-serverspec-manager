# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe 'Checking f2k' do
  describe package('f2k') do
    it { should be_installed }
  end

  describe service('f2k') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(2055) do
    it { should be_listening }
  end

  describe 'Registered in consul' do
    let(:service_name) { 'f2k' }
    let(:api_endpoint) { 'http://localhost:8500/v1' }
    let(:service_json) { command("curl -s #{api_endpoint}/catalog/service/#{service_name} | jq -r '.[]'").stdout }
    let(:health) do
      command("curl -s #{api_endpoint}/health/service/#{service_name} | jq -r '.[].Checks[0].Status'").stdout.strip
    end
    let(:registered) { JSON.parse(service_json).key?('Address') && health == 'passing' }

    it 'is registered in Consul' do
      expect(registered).to be true
    end
  end
end
