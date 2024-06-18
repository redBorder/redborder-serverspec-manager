# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe file('/usr/lib/redborder/bin/rb_wakeup_chef.sh'), :rb_wakeup_chef do
  it { should exist }
  it { should be_file }
  it { should be_executable.by_user('webui') }
end

describe 'Checking WakeUpClusterJob' do
  query_psql = "echo \"SELECT * FROM stored_delayed_jobs WHERE job='RbWakeupChefClusterJob';\" | rb_psql redborder"
  describe command(query_psql) do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should_not match(/Errno::EACCES: Permission denied/) }
  end
end
