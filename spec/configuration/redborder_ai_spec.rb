# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

is_package_installed = package('redborder-ai').installed?

if is_package_installed
  describe 'Check ai config' do
    describe file('/etc/redborder-ai/resources/drop_in/override.conf') do
      it { should exist }
      it { should be_file }
    end
  end
end
