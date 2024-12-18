# frozen_string_literal: true

require 'serverspec'
require 'net/ssh'
require 'tempfile'

set :backend, :ssh
set :disable_sudo, true

# spec/spec_helper.rb

# Check if IS_CLUSTER environment variable is already set
ENV['IS_CLUSTER'] ||= 'true' unless ENV.key?('IS_CLUSTER') && ENV['IS_CLUSTER'] == 'false'

# ssh setup
ENV['TARGET_HOST'] ||= '10.0.209.20'
host = ENV['TARGET_HOST']
options = Net::SSH::Config.for(host)
set :host, options[:host_name] || host
options[:user] ||= ENV['LOGIN_USERNAME'] || 'root'

options[:password] = if ENV['ASK_LOGIN_PASSWORD']
                       ask("\nEnter login password: ") { |q| q.echo = false }
                     else
                       ENV['LOGIN_PASSWORD'] || 'redborder'
                     end
set :ssh_options, options
