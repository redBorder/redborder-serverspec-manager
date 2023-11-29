# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w(
  redborder-druid cookbook-druid druid
)

describe 'Checking druid-realtime' do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  describe service('druid-realtime') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8084) do
    it { should be_listening }
  end
end