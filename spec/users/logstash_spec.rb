# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe user('logstash') do
  it { should exist }
  it { should belong_to_group 'virusgroup' }
end
