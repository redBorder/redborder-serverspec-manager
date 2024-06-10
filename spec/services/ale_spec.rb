# frozen_string_literal: true

require 'spec_helper'
require 'set'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'redborder-ale'
package = 'redborder-ale'

describe "Checking packages for #{service}..." do
    describe package(package) do
      before do
        skip("#{package} is not installed, skipping...") unless package(package).installed?
      end

      it 'is expected to be installed' do
        expect(package(package).installed?).to be true
      end
    end
end

service_status = command("systemctl is-enabled #{service}").stdout.strip
describe "Checking #{service_status} service for #{service}..." do
  describe service(service) do
    if service_status == 'enabled'
      it { should be_enabled }
      it { should be_running }
    end
  end
end

describe 'Redborder-ale is using correct ruby setup' do
  if service_status == 'enabled'
    describe command('sudo -u redborder-ale which ruby') do
      its(:stdout) { should match %r{/usr/lib/rvm/rubies/ruby-2.7.5/bin/ruby} }
    end
  elsif service_status == 'disabled'
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
end
