require 'spec_helper'
set :os, :family => 'redhat', :release => '9', :arch => 'x86_64'

describe package('nginx') do
  it { should be_installed }
end

describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

