# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe file('/usr/lib/redborder/bin/rb_wakeup_chef.sh'), :rb_wakeup_chef do
  it { should exist }
  it { should be_file }
  it { should be_executable.by_user('webui') }
end
