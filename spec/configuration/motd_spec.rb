# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

# Verificar que existe un script MOTD en el sistema
describe file('/usr/lib/redborder/bin/motd') do
  it { should exist }
  it { should be_executable }
end

# Verificar la existencia del archivo MOTD en /etc/motd y su contenido
describe file('/etc/motd') do
  it { should exist }
  its('content') { should match(/.*redborder-repo.*/) }
end
