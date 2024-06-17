# frozen_string_literal: true

require 'spec_helper'
require 'set'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'redborder-ale'

is_package_installed = package('redborder-ale').installed?

if is_package_installed
  service_status = command("systemctl is-enabled #{service}").stdout.strip
  describe "Checking #{service_status} service for #{service}..." do
    if service_status == 'enabled'
      describe service(service) do
        it { should be_enabled }
        it { should be_running }
      end
    elsif service_status == 'disabled'
      describe service(service) do
        it { should_not be_enabled }
        it { should_not be_running }
      end
    end
  end
end
