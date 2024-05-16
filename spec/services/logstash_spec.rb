# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  logstash redborder-logstash-plugins cookbook-logstash logstash-rules
]

service = 'logstash'
port = 9600
hostname = command('hostname -s').stdout

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
  describe "Checking #{service_status} service for #{service}..." do
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(port) do
      it { should be_listening }
    end
  end
end

if service_status == 'disabled'
  describe "Checking #{service_status} service for #{service}..." do
    describe service(service) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

    describe port(port) do
      it { should_not be_listening }
    end
  end
end

describe 'Pipelines status' do
  describe command("knife node show #{hostname} --attribute default.redborder.logstash") do
    its('exit_status') { should eq 0 }
    its('stdout') do
      # Parse JSON output and check if ATTRIBUTE_NAME is empty
      json_output = JSON.parse(subject.stdout)
      attribute_value = json_output['pipelines']

      if attribute_value.nil? || attribute_value.empty?
        describe service(service) do
          it { should_not be_enabled }
          it { should_not be_running }
        end
      end
    end
  end
end
