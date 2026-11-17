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

  # Sync network API (no TLS, decision M3 B): the Consul check and joining managers use it; standbys answer 200 too
  describe command(%q|curl -s -o /dev/null -w '%{http_code}' "$(awk -F'"' '/^api_addr/{print $2}' /etc/openbao/openbao.hcl)/v1/sys/health?standbyok=true"|) do
    its(:stdout) { should eq '200' }
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
  end

  # Count only: a failing content match would print the password. Any long value: new installs get 64 hex
  # characters from rb_openbao init, migrated installs keep their old password.
  describe command("grep -cE '^requirepass [[:alnum:]]{32,}$' /run/rb-secrets/redis/auth.conf") do
    its(:stdout) { should eq "1\n" }
  end

  describe service('redis') do
    it { should be_running }
  end

  # Redis/Sentinel config rewrites (failover) must not put the password into /etc/redis
  describe command("grep -rlE '^(requirepass|masterauth|sentinel auth-pass) ' /etc/redis") do
    its(:stdout) { should eq '' }
  end
end

describe 'Memory stays off disk' do
  describe command('swapon --show=NAME --noheadings') do
    its(:stdout) { should_not match(%r{^/dev/(sd|vd|nvme|mapper/rl)}) }
  end

  describe command('cryptsetup status swap') do
    its(:stdout) { should match(/cipher:\s+aes-xts-plain64/) }
    its(:stdout) { should match(/keysize:\s+512 \[bits\]/) }
  end

  describe file('/proc/cmdline') do
    its(:content) { should_not match(/resume=/) }
  end

  # kdump may run, but must only save the kernel log, never a memory image
  describe command("grep '^core_collector ' /etc/kdump.conf 2>/dev/null || echo none") do
    its(:stdout) { should match(/\A(core_collector makedumpfile --dump-dmesg|none)\n\z/) }
  end

  describe command('find /var/crash -name vmcore -size +10M 2>/dev/null | wc -l') do # a kernel log is fine, a RAM image is not
    its(:stdout) { should match(/^0$/) }
  end

  describe command('systemd-analyze cat-config systemd/coredump.conf') do
    its(:stdout) { should match(/^Storage=none/) }
  end

  describe command('sysctl -n fs.suid_dumpable') do
    its(:stdout) { should eq "0\n" }
  end
end
