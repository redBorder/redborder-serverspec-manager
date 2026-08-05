# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe 'Checking redborder cgroups v2 systemd slice' do
  describe file('/etc/systemd/system/redborder.slice') do
    it { should exist }
  end
end
