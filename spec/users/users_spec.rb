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

  allowed_users = Set.new %w[root redborder]
  not_allowed_users = bash_users - allowed_users

  it 'should only allow specified users to have login permissions' do
    expect(not_allowed_users).to be_empty
  end
end
