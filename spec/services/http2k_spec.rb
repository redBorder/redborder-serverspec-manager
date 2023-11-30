# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe package('redborder-http2k') do
  it { should be_installed }
end

describe service('http2k') do
  it { should be_enabled }
  it { should be_running }
end

describe port(7980) do
  it { should be_listening }
end
