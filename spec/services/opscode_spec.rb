# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

internal_services = %w[
  nginx oc_bifrost oc_id opensearch redis_lb opscode-erchef
]

describe 'Check Chef Server services' do
  internal_services.each do |service|
    describe command("chef-server-ctl status #{service}") do
      it "The service #{service} is down" do
        if subject.stdout.empty?
          puts "The #{service} status is not available."
        else
          puts "The #{service} status is available"
          expect(subject.stdout).to match(/down:/)
        end
      end
    end
  end
end
