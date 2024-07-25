# frozen_string_literal: true

require 'spec_helper'
require 'json'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe 'Memcached config in webui' do
  describe file('/var/www/rb-rails/config/memcached_config.yml') do
    it { should exist }
    it { should be_file }
    it { should_not contain 'localhost' }
  end
end
