# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe file('/etc/pmacct/sfacctd.conf') do
  it { should exist }
end

describe service('sfacctd') do
  it { should be_enabled }
  it { should be_running }
end

describe port(6343) do
  it { should be_listening }
end
