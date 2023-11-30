# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe 'Checking Memcached Service - Basic Checks' do
  # Verifies the installation of the Memcached package.
  describe package('memcached') do
    it { should be_installed }
  end

  # Checks the status of the Memcached service.
  describe service('memcached') do
    it { should be_enabled }
    it { should be_running }
  end

  # Verifies the basic configuration of Memcached.
  describe 'Configuration' do
    describe file('/usr/lib/sysusers.d/memcached.conf') do
      it { should exist }
    end
  end
end

describe 'Checking Memcached Service - Advanced Checks' do
  # Checks network and connectivity aspects.
  describe 'Network and Connectivity' do
    describe port(11_211) do
      it { should be_listening }
    end
  end

  # Verifies the Memcached logs.
  describe 'Memcached Logs' do
    describe file('/var/log/memcached.log') do
      its(:content) { should_not match(/error/i) }
    end
  end

  # Verifies the user running the Memcached process.
  describe 'Process User' do
    describe command("ps aux | grep [m]emcached | awk '{print $1}'") do
      its(:stdout) { should match(/memcach\+/) }
    end
  end
end
