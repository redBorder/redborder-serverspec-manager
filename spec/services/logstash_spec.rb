# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  logstash redborder-logstash-plugins cookbook-logstash logstash-rules
]

describe 'Checking logstash' do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  describe service('logstash') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(9600) do
    it { should be_listening }
  end
end
