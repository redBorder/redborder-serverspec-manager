# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'rb-workers'

service_status = command("systemctl is-enabled #{service}").stdout
service_status = service_status.strip

if service_status == 'enabled'
  describe "Checking #{service_status} service for #{service}..." do
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
