# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'redborder-ale'
service_status = command("systemctl is-enabled #{service}").stdout.strip
packages = %w[redborder-ale]

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

describe "Checking #{service_status} service for #{service}..." do
  describe service(service) do
    if service_status == 'enabled'
      it { should be_enabled }
      it { should be_running }
    elsif service_status == 'disabled'
      it { should_not be_enabled }
      it { should_not be_running }
    end
  end
end

describe "Checking for config files of #{service}" do
  describe file('/etc/redborder-ale/config.yml') do
    it { should exist }
  end
  describe file('/etc/redborder-ale/rb_ale_aps.conf') do
    it { should exist }
  end
end
