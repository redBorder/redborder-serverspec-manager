# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

# LINCE/CCN: no credentials or keys in plaintext on persistent storage.
# Services get their secrets from the OpenBao agent, rendered into /run (memory).

describe 'OpenBao' do
  describe service('openbao') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('openbao-agent') do
    it { should be_enabled }
    it { should be_running }
  end

  describe command('BAO_ADDR=unix:///run/openbao/openbao.sock bao status -format=json') do
    its(:stdout) { should match(/"initialized": true/) }
    its(:stdout) { should match(/"sealed": false/) }
  end

  describe file('/run/openbao-agent/canary') do
    its(:content) { should eq 'ok' }
  end

  describe file('/run/openbao/tls.key') do
    it { should be_mode 600 }
    it { should be_owned_by 'openbao' }
  end
end

describe 'No secret values on disk' do
  describe command('rb_openbao scan') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/^OK: none of \d+ secret values found on disk/) }
  end
end

describe 'Redis reads its password from memory' do
  describe file('/etc/redis/redis-base.conf') do
    it { should contain 'include /run/rb-secrets/redis/auth.conf' }
    it { should_not contain(/^requirepass/) }
  end

  describe file('/run/rb-secrets/redis/auth.conf') do
    it { should be_mode 640 }
    it { should be_grouped_into 'redis' }
    it { should contain(/^requirepass \h{64}$/) }
  end

  describe service('redis') do
    it { should be_running }
  end
end

describe 'Memory stays off disk' do
  describe command('swapon --show=NAME --noheadings') do
    its(:stdout) { should_not match(%r{^/dev/(sd|vd|nvme|mapper/rl)}) }
  end

  describe command('cryptsetup status swap') do
    its(:stdout) { should match(/cipher:\s+aes-xts-plain64/) }
    its(:stdout) { should match(/keysize:\s+512 bits/) }
  end

  describe file('/proc/cmdline') do
    its(:content) { should_not match(/resume=/) }
  end

  describe service('kdump') do
    it { should_not be_running }
    it { should_not be_enabled }
  end

  describe command('systemd-analyze cat-config systemd/coredump.conf') do
    its(:stdout) { should match(/^Storage=none/) }
  end

  describe command('sysctl -n fs.suid_dumpable') do
    its(:stdout) { should eq "0\n" }
  end
end
