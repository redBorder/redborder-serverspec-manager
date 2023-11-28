# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe 'Checking net-snmp' do
  describe package('net-snmp') do
    it { should be_installed }
  end

  describe service('snmpd') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(199) do
    it { should be_listening }
  end
end
