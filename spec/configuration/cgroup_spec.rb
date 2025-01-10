# frozen_string_literal: true

require 'spec_helper'
require 'set'
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

hostname = command('hostname -s')
excluded_memory_services = command("knife node show #{hostname} -l -F json | " \
                                   "jq '.default.redborder.excluded_memory_services | keys[]'").split("\n")

describe 'Check excluded memory service' do
  it 'Check chef-client is a excluded memory service' do
    expect(excluded_memory_services).to include('chef-client')
  end

  excluded_memory_services.each do |service|
    describe command("systemctl show --property Slice --value #{service}") do
      its('stdout') { should eq 'system.slice' }
    end
  end
end

memory_services = command("knife node show #{hostname} -l -F json | " \
                          "jq '.default.redborder.memory_services | keys[]'").split("\n")
[memory_services, excluded_memory_services].map! { |array| Set.new(array) }
non_excluded_serv = memory_services.difference(excluded_memory_services)

describe 'Checking Slices of Non Excluded Memory Services' do
  non_excluded_serv.each do |service|
    describe command("systemctl show --property Slice --value #{service}") do
      no_dash = service.gsub('-', '')
      its('stdout') { should eq "redborder-#{no_dash}.slice" }
    end
  end
end
