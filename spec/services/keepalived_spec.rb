# frozen_string_literal: true

require 'spec_helper'
require 'set'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  keepalived cookbook-keepalived
]

service = 'keepalived'

describe "Checking packages for #{service}..." do
  packages.each do |package|
    describe package(package) do
      before do
        skip("#{package} is not installed, skipping...") unless package(package).installed?
      end

      it 'is expected to be installed' do
        expect(package(package).installed?).to be true
      end
    end
  end
end

service_status = command("systemctl is-enabled #{service}").stdout
service_status = service_status.strip

if service_status == 'enabled'
  describe service(service) do
    it { should be_enabled }
    it { should be_running }
  end

  describe 'Keepalived Configuration Files' do
    describe file('/etc/keepalived/keepalived.conf') do
      it { should exist }
      it { should be_owned_by 'root' }
    end
  end
end

if service_status == 'disabled'
  describe "Checking #{service_status} service for #{service}..." do
    describe service(service) do
      it { should_not be_enabled }
      it { should_not be_running }
    end
  end
end
