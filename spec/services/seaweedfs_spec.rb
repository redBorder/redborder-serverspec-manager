# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

# SeaweedFS (S3): filer + S3 gateway and volume server in every S3 manager, master in the
# first ones (Raft)
package = 'redborder-seaweedfs'
services = {
  'seaweedfs-filer' => %w[9350 19350 8333],
  'seaweedfs-volume' => %w[9340 19340],
  'seaweedfs-master' => %w[9333 19333]
}

describe "Checking packages for #{package}..." do
  describe package(package) do
    before do
      skip("#{package} is not installed, skipping...") unless package(package).installed?
    end

    it 'is expected to be installed' do
      expect(package(package).installed?).to be true
    end
  end
end

services.each do |service, ports|
  service_status = command("systemctl is-enabled #{service}").stdout.strip
  next unless service_status == 'enabled'

  describe "Checking #{service_status} service for #{service}..." do
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end

    ports.each do |p|
      describe port(p.to_i) do
        it { should be_listening }
      end
    end

    describe file("/etc/default/#{service}") do
      it { should exist }
    end
  end
end

if command('systemctl is-enabled seaweedfs-filer').stdout.strip == 'enabled'
  describe 'Checking the SeaweedFS configuration...' do
    %w[/etc/seaweedfs/s3.json /etc/seaweedfs/security.toml].each do |config|
      describe file(config) do
        it { should exist }
        it { should be_mode 640 }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'seaweedfs' }
      end
    end

    describe file('/etc/seaweedfs/security.toml') do
      its(:content) { should match(/^\[jwt\.signing\]\nkey = "[0-9a-f]{64}"/) }
      its(:content) { should match(/^\[jwt\.filer_signing\]\nkey = "[0-9a-f]{64}"/) }
    end
  end
end

if command('systemctl is-enabled seaweedfs-master').stdout.strip == 'enabled'
  describe file('/etc/default/seaweedfs-master') do
    its(:content) { should match(/-telemetry=false/) }
  end
end
