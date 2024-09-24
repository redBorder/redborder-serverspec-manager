# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

packages = %w[
  redborder-druid cookbook-druid druid
]
service = 'druid-coordinator'
consul_api_endpoint = 'http://localhost:8500/v1'

describe "Checking #{packages}" do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  describe service(service) do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8084) do
    it { should be_listening }
  end

  describe 'Registered in consul' do
    get_service_json_cmd = "curl -s #{consul_api_endpoint}/catalog/service/#{service} | jq -c 'group_by(.ID)[]'"
    service_json_cluster = command(get_service_json_cmd)
    service_json_cluster = service_json_cluster.stdout.chomp.split("\n")
    health_cluster = command("curl -s #{consul_api_endpoint}/health/service/#{service} | jq -r '.[].Checks[0].Status'")
    health_cluster = health_cluster.stdout.chomp.split("\n")
    service_and_health = service_json_cluster.zip(health_cluster)
    service_and_health.each do |srv, health|
      registered = JSON.parse(srv)[0].key?('Address') && health == 'passing' # ? true : false
      it 'Should be registered and enabled' do
        expect(registered).to be true
      end
    end
  end

  describe 'Druid should have at least one rule without forever duration' do
    # Sample of wrong
    # {"_default":[{"tieredReplicants":{"_default_tier":2},"type":"loadForever"}]}
    # Sample of expected
    # {"_default":[
    #     {"period":"P1M","tieredReplicants":{"_default_tier":1},"type":"loadByPeriod"},{"type":"dropForever"}
    #     ]}

    get_default_rules_cmd = "curl -X GET http://#{service}.service:8081/druid/coordinator/v1/rules/"
    describe command(get_default_rules_cmd) do
      its(:exit_status) { should eq 0 }
      it 'should have at least one rule without forever duration' do
        skip('Skipping test due to empty stdout') if subject.stdout.empty?

        rules = JSON.parse(subject.stdout)['_default']
        non_forever_rule = rules.any? do |rule|
          rule['type'] != 'loadForever' && rule['type'] != 'dropForever'
        end
        expect(non_forever_rule).to be true
      end
    end
  end
end
