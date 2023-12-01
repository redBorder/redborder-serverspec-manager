# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  logstash redborder-logstash-plugins cookbook-logstash logstash-rules
]

service = 'logstash'

describe "Checking #{service}..." do
  packages.each do |package|
    describe package(package) do
      before do
        unless package(package).installed?
          skip("#{package} is not installed, skipping...")
        end
      end
  
      it 'is expected to be installed' do
        expect(package(package).installed?).to be true
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

    describe port(9600) do
      it { should be_listening }
    end
  else # if service disabled
    describe service(service) do
      it { should_not be_enabled }
      it { should_not be_running }
    end
  
    describe port(8300) do
      it { should_not be_listening }
    end
  end
end
