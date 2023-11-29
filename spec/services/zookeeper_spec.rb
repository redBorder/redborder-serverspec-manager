# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe service('zookeeper') do
  it 'Should the Zookeeper package be installed' do
    expect(package('zookeeper')).to be_installed
  end

  it 'Should the Zookeeper service be running' do
    expect(service('zookeeper')).to be_running
  end

  it 'Should it be listening on port 2181' do
    expect(port(2181)).to be_listening
  end
end
