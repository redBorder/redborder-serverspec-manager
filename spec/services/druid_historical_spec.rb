# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  redborder-druid cookbook-druid druid
]

describe 'Checking Druid Historical Service' do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  describe service('druid-historical') do
    it { should be_enabled }
    it { should be_running }
  end

  describe 'Configuration' do
    describe file('/usr/lib/druid/conf/druid/historical/jvm.config') do
      it { should exist }
    end
  end

  describe 'System Dependencies' do
    describe package('java-1.8.0-openjdk') do
      it { should be_installed }
    end
  end

  describe 'Network and Connectivity' do
    describe port(8083) do
      it { should be_listening }
    end
  end

  describe 'Druid Historical Logs' do
    describe file('/var/log/druid/historical.log') do
      its(:content) { should_not match(/ERROR/) }
    end
  end
end
