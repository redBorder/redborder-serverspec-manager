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

    # rb-bootstrap runs once (RemainAfterExit): it stays 'active (exited)' until the node
    # is rebooted, after that it is 'inactive (dead)'. Both are fine, a failed run is not.
    it "is expected to be 'active (exited)' or 'inactive (dead)'" do
      active_state = command("systemctl show -p ActiveState --value #{service}").stdout.strip
      sub_state = command("systemctl show -p SubState --value #{service}").stdout.strip
      expect("#{active_state} (#{sub_state})").to eq('active (exited)').or eq('inactive (dead)')
    end

    it 'is expected not to have failed' do
      expect(command("systemctl show -p Result --value #{service}").stdout.strip).to eq 'success'
    end
  end
end
