# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  redborder-vortex cookbook-vortex
]

service = 'redborder-vortex'
SOCKET_PATH = '/run/redborder-vortex/redborder-vortex.sock'
PIPELINES_PATH = '/etc/redborder-vortex/pipelines.yml'

describe "Checking service status for #{service}..." do
  regex = '^- pipeline\.id: .*-pipeline$'
  has_pipelines = command("grep --perl-regex '#{regex}' #{PIPELINES_PATH}").exit_status == 0

  if has_pipelines
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end
    describe file(SOCKET_PATH) do
      it { should be_socket }
    end

    packages.each do |package|
      describe package(package) do
        it { should be_installed }
      end
    end
  else
    describe service(service) do
      it { should_not be_enabled }
      it { should_not be_running }
    end
  end
end
