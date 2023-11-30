# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  redborder-cgroups
]

describe 'Checking redborder cgroups packages' do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  describe service('redborder-cgroups') do
    it { should be_enabled }
  end

  describe 'Configuration' do
    describe file('/etc/cgroup.conf') do
      it { should exist }
    end
  end
end
