# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

is_package_installed = package('redborder-ale').installed?

if is_package_installed
  describe 'Check ale config' do
    describe file('/etc/redborder-ale/schema.pb.rb') do
      it { should exist }
      it { should be_file }
    end

    describe file('/etc/redborder-ale/config.yml') do
      it { should exist }
      it { should be_file }
    end

    describe file('/etc/redborder-ale/rb_ale_aps.conf') do
      it { should exist }
      it { should be_file }
    end
  end

  describe file('/var/rb-ale/bin/rb_ale.rb') do
    it { should exist }
    it { should be_file }
    it { should be_executable.by(:owner) }
    it { should be_executable.by(:group) }
    its(:content) { should match(%r{^(\s*#.*|)#!/usr/bin/env\s+ruby.*$}) }
  end

  describe file('/usr/bin/rb_scan_ale.rb') do
    it { should exist }
    it { should be_file }
    it { should be_executable.by(:owner) }
    it { should be_executable.by(:group) }
  end
end
