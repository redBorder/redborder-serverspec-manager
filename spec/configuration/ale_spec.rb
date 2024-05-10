# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

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

describe 'Redborder-Ale user config' do
  describe command('sudo -u redborder-ale bash -lc "ruby -v"') do
    its(:stdout) { should match /ruby 2.7.5/ }
  end

# Notice this is a bash session, when closed the gemset will change to default
  describe command('sudo -u redborder-ale bash -lc "rvm gemset list"') do
    its(:stdout) { should match /\=\>\s*global/ }
  end
end