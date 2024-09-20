# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

pkg = usr = 'zookeeper'
describe user(usr) do
  before(:all) do
    skip("Package #{pkg} is not installed") unless package(pkg).installed?
  end
  it { should exist }
  it { should have_login_shell('/sbin/nologin') }
end
