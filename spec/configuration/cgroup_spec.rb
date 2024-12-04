# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

cgroups = command('find /sys/fs/cgroup/redborder.slice -type d -name "redborder-*" -not -name "*.service"').stdout.split

describe 'Check cgroups config' do
  describe file('/sys/fs/cgroup/redborder.slice') do
    it { should exist }
  end

  cgroups.each do |cgroup|
    describe file("#{cgroup}/cgroup.controllers") do
      it { should exist }
      it { should be_file }
      its(:content) { should match(/io/) }
    end

    describe file("#{cgroup}/memory.max") do
      it { should exist }
      it { should be_file }
      its(:content) { should match(/^max|\d+$/) }
    end

    describe file("#{cgroup}/memory.high") do
      it { should exist }
      it { should be_file }
      its(:content) { should match(/^\d+$/) }
    end

    describe file("#{cgroup}/io.bfq.weight") do
      it { should exist }
      it { should be_file }
      its(:content) { should match(/^default\s\d+$/) }
    end
  end
end

describe file('/usr/lib/redborder/bin/rb_check_cgroups'), :rb_check_cgroups do
  it { should exist }
  it { should be_file }
  it { should be_executable }
end

describe file('/usr/lib/redborder/bin/rb_check_cgroups.sh'), :rb_check_cgroups do
  it { should exist }
  it { should be_file }
  it { should be_executable }
end

describe file('/usr/lib/redborder/scripts/rb_check_cgroups.rb'), :rb_check_cgroups do
  it { should exist }
  it { should be_file }
  it { should be_executable.by(:owner) }
  it { should be_executable.by(:group) }
  its(:content) { should match(%r{^(\s*#.*|)#!/usr/bin/env\s+ruby.*$}) }
end
