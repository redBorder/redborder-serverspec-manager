# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe user('sshd') do
  it { should exist }
  it { should have_login_shell('/usr/sbin/nologin') }
end
