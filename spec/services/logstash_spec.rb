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
  has_pipelines = command("grep --perl-regex '#{regex}' #{PIPELINES_PATH}").exit_status == 0
  expected_state = has_pipelines ? :be_enabled : :not_be_enabled
  expected_running = has_pipelines ? :be_running : :not_be_running
  expected_listening = has_pipelines ? :be_listening : :not_be_listening
  expected_installed = has_pipelines ? :be_installed : :not_be_installed

  describe service(service) do
    it { should send(expected_state) }
    it { should send(expected_running) }
  end

  describe port(port) do
    it { should send(expected_listening) }
  end

  packages.each do |package|
    describe package(package) do
      it { should send(expected_installed) }
    end
  end
end
