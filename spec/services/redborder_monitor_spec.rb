# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  redborder-monitor cookbook-rb-monitor
]
describe 'Checking redborder-monitor...' do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  describe service('redborder-monitor') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/redborder-monitor/config.json') do
    it { should exist }
    it { should be_file }
  end
end
