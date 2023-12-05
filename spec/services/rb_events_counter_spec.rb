# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'redborder-events-counter'
port = 5000
service_status = command("systemctl is-enabled #{service}").stdout.strip

if service_status == 'enabled'
  describe 'Redborder Events Counter Service Checks for Enabled Service' do
    describe service(service) do
      it 'should be enabled' do
        expect(subject).to be_enabled
      end

      it 'should be running' do
        expect(subject).to be_running
      end
    end

    describe port(port) do
      it 'should be listening' do
        expect(subject).to be_listening
      end
    end
  end
end

if service_status == 'disabled'
  describe 'Redborder Events Counter Service Checks for Disabled Service' do
    describe service(service) do
      it 'should not be enabled' do
        expect(subject).not_to be_enabled
      end

      it 'should not be running' do
        expect(subject).not_to be_running
      end
    end

    describe port(port) do
      it 'should not be listening' do
        expect(subject).not_to be_listening
      end
    end
  end
end

describe 'Redborder Events Counter Configuration and Logs' do
  describe file('/ruta/a/tu/archivo/de/configuracion') do
    it 'should exist' do
      expect(subject).to exist
    end
  end

  describe file('/ruta/a/tu/archivo/de/log') do
    it 'should exist' do
      expect(subject).to exist
    end
  end
end
