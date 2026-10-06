# frozen_string_literal: true

# This file is for system users in general

require 'spec_helper'
require 'set'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe 'Checking only these users has login permission' do
  passwd = command('cat /etc/passwd').stdout.split("\n")
  bash_users = passwd.select { |p| p.include? '/bin/bash' }
  bash_users.map! { |p| p.split(':').first }
  bash_users = Set.new bash_users

  allowed_users = Set.new %w[root redborder postgres minio malware]
  not_allowed_users = bash_users - allowed_users

  describe 'users with login permissions' do
    it 'should only allow specified users' do
      expect(not_allowed_users.to_a).to be_empty, "Unexpected users with login permissions: #{not_allowed_users.to_a}"
    end
  end
end

describe user('redborder-alarm-engine') do
  before(:all) do
    skip('Package redborder-alarm-engine is not installed') unless package('redborder-alarm-engine').installed?
  end

  it { should exist }
  it { should have_login_shell('/sbin/nologin') }
end
