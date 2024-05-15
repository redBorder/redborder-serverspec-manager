# frozen_string_literal: true

require 'spec_helper'
require 'set'

set :os, family: 'redhat', release: '9', arch: 'x86_64'
SERVICE = 'redborder-ale'
MUST_INSTALLED_PKGS = Set.new(%w[cookbook-rb-ale])

describe "Checking packages for #{SERVICE}..." do
  MUST_INSTALLED_PKGS.each do |package|
    describe package(package) do
      it 'is expected to be installed' do
        expect(package(package).installed?).to be true
      end
    end
  end
end

INSTALLED_WHEN_NEEDED_PKGS = Set.new(%w[redborder-ale])
are_pkgs_installed = MUST_INSTALLED_PKGS.merge(INSTALLED_WHEN_NEEDED_PKGS).all? do |pkg|
  package(pkg).installed?
end

service_status = command("systemctl is-enabled #{SERVICE}").stdout.strip
describe "Checking #{service_status} service for #{SERVICE}..." do
  describe service(SERVICE) do
    if service_status == 'enabled'
      it { should be_enabled }
      it { should be_running }
      expect(are_pkgs_installed).to be true
    elsif service_status == 'disabled'
      it { should_not be_enabled }
      it { should_not be_running }
    end
  end
end

command_to_check = '/usr/lib/rvm/rubies/ruby-2.7.5/bin/ruby'
describe command("sudo -u #{SERVICE} #{command_to_check} -e 'exit 0' 2>&1") do
  its(:exit_status) { should eq 0 }
end
