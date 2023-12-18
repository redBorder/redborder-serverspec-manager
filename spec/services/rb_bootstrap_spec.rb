# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'rb-bootstrap'
service_status = command("systemctl is-enabled #{service}").stdout.strip

describe "Checking service status for #{service}..." do
  describe service(service) do
    if service_status == 'enabled'
      it { should be_enabled }
    else
      it { should_not be_enabled }
    end

    it "is expected to be in a state of 'active (exited)'" do
      expect(command("systemctl show -p ActiveState --value #{service}").stdout.strip).to eq 'active'
      expect(command("systemctl show -p SubState --value #{service}").stdout.strip).to eq 'exited'
    end
  end
end
