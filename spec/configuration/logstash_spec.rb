# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe 'Check logstash config' do
  describe file('/etc/kafka/topics_definitions.yml') do
    it { should exist }
    it { should be_file }
    it { should be_readable }
    it { should be_writable.by_user('kafka') }
    it { should_not be_writable.by('others') }
    it { should_not be_executable }
  end
end
