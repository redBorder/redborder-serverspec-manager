# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[clamd]

packages.each do |pkg|
  describe "#{pkg} package and its config file" do
    let(:package_resource) { package(pkg) }

    before do
      skip("#{pkg} is not installed, skipping...") unless package_resource.installed?
    end

    describe package(pkg) do
      it { should be_installed }
    end

    describe file('/etc/clamd.d/scan.conf') do
      it { should exist }
      it { should be_file }
      # it { should be_readable.by('virusgroup') }
      # it { should be_writable.by('clamscan') }
      it { should_not be_executable }
      its(:content) { should match(/LocalSocketGroup\s+virusgroup$/) }
    end

    describe file('/usr/lib/tmpfiles.d/clamd.scan.conf') do
      it { should exist }
      it { should be_file }
      it { should_not be_executable }
      its(:content) { should match(/clamscan\s+virusgroup\s*$/) }
    end
  end
end
