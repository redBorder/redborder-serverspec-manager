# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'rb-bootstrap'
describe "Checking service status for #{service}..." do
  describe service(service) do
    active_state = command("systemctl show -p ActiveState --value #{service}").stdout.strip
    active_status = command("systemctl is-active #{service}").exit_status
    if active_state == 'inactive'
      it { should_not be_enabled }
      it { expect(active_status).to eq(3) } # 3 is not running
      failed_status = command("systemctl is-failed #{service}").exit_status
      it { expect(failed_status).to eq(1) } # 1 has finished with success
    elsif active_state == 'active'
    # On setup the service has to be active
      # it { should be_enabled }
      it { expect(active_status).to eq(0) } # 0 is running
    end
  end
end
