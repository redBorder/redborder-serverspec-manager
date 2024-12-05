# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe service('firewalld') do
  it { should be_running }
  it { should be_enabled }
end

describe command('firewall-cmd --reload') do
  its(:exit_status) { should eq 0 }
end
