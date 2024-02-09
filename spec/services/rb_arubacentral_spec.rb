# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'rb-arubacentral'
service_status = command("systemctl is-enabled #{service}").stdout.strip
packages = %w[cookbook-rb-arubacentral]

describe "Checking packages for #{service}..." do
  packages.each do |p|
    describe package(p) do
      before do
        skip("#{p} is not installed, skipping...") unless package(p).installed?
      end

      it 'is expected to be installed' do
        expect(package(p).installed?).to be true
      end
    end
  end
end

if service_status == 'enabled'
  describe "Checking #{service_status} service for #{service}..." do
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe "Checking config file for #{service}..." do
    describe file("/etc/#{service}/config.yml") do
      it { should exist }
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
