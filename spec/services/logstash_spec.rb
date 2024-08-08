# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  logstash redborder-logstash-plugins cookbook-logstash logstash-rules
]

service = 'logstash'
port = 9600
HOSTNAME = command('hostname -s').stdout.chomp
PIPELINES_PATH = '/etc/logstash/pipelines.yml'

describe "Checking service status for #{service}..." do
  regex = '^- pipeline\.id: .*-pipeline$'
  has_pipelines = command("grep --perl-regex '#{regex}' #{PIPELINES_PATH}")

  unless has_pipelines.exit_status == 0
    describe service(service) do
      it { should_not be_enabled }
      it { should_not be_running }
    end
    describe port(port) do
      it { should_not be_listening }
    end

    packages.each do |package|
      describe package(package) do
        it { should_not be_installed }
      end
    end

  end

  if has_pipelines.exit_status == 0
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end
    describe port(port) do
      it { should be_listening }
    end

    packages.each do |package|
      describe package(package) do
        it { should be_installed }
      end
    end

  end
end
