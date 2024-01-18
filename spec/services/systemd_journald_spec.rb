# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe 'Checking systemd-journald' do
  describe service('systemd-journald') do
    it { should be_enabled }
    it { should be_running }
  end

  describe 'Configuration' do
    describe file('/etc/systemd/journald.conf') do
      it { should exist }
    end
  end
end
