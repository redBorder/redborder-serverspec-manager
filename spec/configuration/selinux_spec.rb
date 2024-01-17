# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

selinux_status = command('getenforce').stdout.chomp
selinux_semodule_package = command('semodule -l | grep redborder').stdout.chomp
puts "SELinux Status: #{selinux_status}"

if selinux_status == 'Enforcing'
  describe 'Checking if redborder package is loaded' do
    it 'redborder SELinux module should be loaded' do
      expect(selinux_semodule_package).to eq('redborder-manager')
    end
  end
else
  describe 'Checking if redborder package is not loaded' do
    it 'redborder SELinux module should not be loaded' do
      expect(selinux_semodule_package).to eq('')
    end
  end
end
