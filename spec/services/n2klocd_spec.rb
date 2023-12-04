# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

service = 'n2klocd' # Reemplaza con el nombre real de tu servicio
port = 1234 # Ajusta de acuerdo con el puerto en el que se ejecuta tu servicio (cambia este número)

service_status = command("systemctl is-enabled #{service}").stdout.strip

if service_status == 'enabled'
  describe 'n2klocd Service Checks for Enabled Service' do
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
  describe 'n2klocd Service Checks for Disabled Service' do
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

describe 'n2klocd Configuration and Logs' do
  # Reemplaza con la ruta a tu archivo de configuración de n2klocd
  describe file('/etc/n2klocd.conf') do
    it 'should exist' do
      expect(subject).to exist
    end
  end

  # Reemplaza con la ruta a tu archivo de registro de n2klocd
  describe file('/var/log/n2klocd.log') do
    it 'should exist' do
      expect(subject).to exist
    end
  end
end
