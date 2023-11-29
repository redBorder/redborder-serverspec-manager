# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe 'Checking chef' do
  describe package('redborder-chef-server') do
    it { should be_installed }
  end

  describe service('chef-client') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/chef/client.rb') do
    it { should exist }
    it { should be_file }
  end
end
