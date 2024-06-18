# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'
packages = %w[
  GeoIP GeoIP-GeoLite-data GeoIP-GeoLite-data-extra geoipupdate geoipupdate-cron
]

describe 'Checking geoip packages family' do
  packages.each do |package|
    describe package(package) do
      it 'is expected to be installed' do
        expect(package(package).installed?).to be true
      end
    end
  end
end

describe 'Check geoip config' do
  describe file('/etc/GeoIP.conf') do
    it { should exist }
    it { should be_file }
    its(:content) { should match(/GeoLite2-ASN/) }
    its(:content) { should match(/GeoLite2-City/) }
    its(:content) { should match(/GeoLite2-Country/) }
  end
end
