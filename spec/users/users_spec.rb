# frozen_string_literal: true
# This file is for system users in general

require 'spec_helper'
require 'set'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe 'Checking only these users has login permission' do
  passwd = command('cat /etc/passwd').stdout.split("\n")
  all_users = passwd.map { |p| p.split(':').first }
  all_users = Set.new all_users

  allowed_users = Set.new %w[root redborder postgres]
  not_allowed_users = all_users - allowed_users

  not_allowed_users.each do |user|
    describe user(user) do
      it { should exist }
      it { should_not have_login_shell('/bin/bash') }
    end
  end
end
